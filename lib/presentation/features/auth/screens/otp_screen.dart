import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  String? _verificationId;
  String _formattedPhone = '';
  int _resendSeconds = 0;
  Timer? _resendTimer;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String _formatIsraeliPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) return '+972${digits.substring(1)}';
    return '+972$digits';
  }

  bool _isValidIsraeliPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && digits.startsWith('05')) return true;
    if (digits.length == 9 && digits.startsWith('5')) return true;
    return false;
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _resendSeconds--; if (_resendSeconds <= 0) t.cancel(); });
    });
  }

  Future<void> _sendOtp() async {
    final raw = _phoneController.text.trim();
    if (!_isValidIsraeliPhone(raw)) {
      context.showSnackBar('הכנס מספר טלפון ישראלי תקין (05X-XXXXXXX)', isError: true);
      return;
    }
    setState(() => _loading = true);
    _formattedPhone = _formatIsraeliPhone(raw);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _formattedPhone,
      verificationCompleted: (credential) async => _verifyWithCredential(credential),
      verificationFailed: (e) {
        if (!mounted) return;
        setState(() => _loading = false);
        context.showSnackBar(e.message ?? 'אימות נכשל, נסה שוב', isError: true);
      },
      codeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _otpSent = true;
          _verificationId = verificationId;
        });
        _startResendTimer();
        _animCtrl.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 200),
            () => _otpFocusNodes[0].requestFocus());
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (!mounted) return;
      final success = await ref.read(authProvider.notifier).verifyOtp(
            phone: _formattedPhone,
            sessionInfo: _verificationId ?? '',
            code: idToken ?? '',
          );
      if (!mounted) return;
      if (!success) context.showSnackBar('אימות נכשל, נסה שוב', isError: true);
    } catch (_) {
      if (!mounted) return;
      context.showSnackBar('קוד שגוי, נסה שוב', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _currentOtp => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_currentOtp.length != 6) {
      context.showSnackBar('הכנס 6 ספרות', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _currentOtp,
      );
      await _verifyWithCredential(credential);
    } catch (_) {
      if (!mounted) return;
      context.showSnackBar('קוד שגוי, נסה שוב', isError: true);
      setState(() => _loading = false);
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.length == 1 && index == 5) {
      _otpFocusNodes[index].unfocus();
      _verifyOtp();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      for (var i = 0; i < 6; i++) _otpControllers[i].text = digits[i];
      setState(() {});
      _otpFocusNodes[5].unfocus();
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _otpSent ? 'אימות קוד' : 'אימות טלפון',
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: _otpSent ? _buildOtpStep() : _buildPhoneStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'מה מספר הטלפון שלך?',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'נשלח לך קוד SMS לאימות',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.amber100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.amber200, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                '+972',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.amber700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: '05X-XXXXXXX',
                  hintStyle: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 15,
                    color: AppColors.textHint,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                onSubmitted: (_) => _sendOtp(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _sendOtp,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('שלח קוד'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'הכנס את הקוד',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Rubik', fontSize: 14, color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'שלחנו קוד ל '),
              TextSpan(
                text: _formattedPhone,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = _otpControllers[i].text.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _OtpBox(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                isFilled: filled,
                onChanged: (v) => _onDigitChanged(i, v),
                onPaste: _handlePaste,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _verifyOtp,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('אמת קוד'),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: _resendSeconds > 0
              ? Text(
                  'שלח שוב בעוד $_resendSeconds שניות',
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              : TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _otpSent = false;
                            for (final c in _otpControllers) c.clear();
                          });
                          _animCtrl.forward(from: 0);
                        },
                  child: const Text('שלח קוד שוב'),
                ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isFilled,
    required this.onChanged,
    required this.onPaste,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFilled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onPaste;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        textDirection: TextDirection.ltr,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isFilled ? AppColors.amber100 : AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isFilled ? AppColors.amber400 : AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isFilled ? AppColors.amber400 : AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) {
          if (v.length > 1) onPaste(v); else onChanged(v);
        },
      ),
    );
  }
}
