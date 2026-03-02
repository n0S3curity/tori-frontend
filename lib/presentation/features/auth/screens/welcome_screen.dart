import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../../core/extensions/context_extensions.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final List<AnimationController> _cardCtrls;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardCtrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _runEntrance();
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _headerCtrl.forward();
    for (var i = 0; i < _cardCtrls.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      _cardCtrls[i].forward();
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loginAs(String role, {String? businessName}) async {
    await ref.read(authProvider.notifier).loginWithGoogle(
          role: role,
          businessName: businessName,
        );
  }

  Future<void> _showBusinessNameDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'שם העסק שלך',
          style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'למשל: מספרת דניאל',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('המשך'),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await _loginAs('businessOwner', businessName: controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthError) {
        context.showSnackBar(next.message, isError: true);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Stack(
        children: [
          Column(
            children: [
              // Header (dark)
              _AnimatedSection(
                controller: _headerCtrl,
                child: _Header(),
              ),

              // Cards (white rounded)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    child: Column(
                      children: [
                        // Role cards
                        _AnimatedCard(
                          controller: _cardCtrls[0],
                          child: _RoleCard(
                            icon: Icons.person_add_rounded,
                            iconBg: AppColors.amber100,
                            iconColor: AppColors.amber600,
                            title: 'אני לקוח חדש',
                            subtitle: 'אני רוצה לקבוע תורים',
                            borderColor: AppColors.amber200,
                            onTap: isLoading ? null : () => _loginAs('client'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedCard(
                          controller: _cardCtrls[1],
                          child: _RoleCard(
                            icon: Icons.business_center_rounded,
                            iconBg: AppColors.infoLight,
                            iconColor: AppColors.info,
                            title: 'רוצה לפתוח עסק',
                            subtitle: 'אני בעל עסק ורוצה לנהל תורים',
                            borderColor: const Color(0xFFBFDBFE),
                            onTap: isLoading ? null : _showBusinessNameDialog,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedCard(
                          controller: _cardCtrls[2],
                          child: _RoleCard(
                            icon: Icons.badge_rounded,
                            iconBg: AppColors.successLight,
                            iconColor: AppColors.successDark,
                            title: 'אני ספק שירות',
                            subtitle: 'אני עובד בעסק ורוצה לנהל את היומן שלי',
                            borderColor: const Color(0xFFA7F3D0),
                            onTap:
                                isLoading ? null : () => _loginAs('serviceProvider'),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Already have account
                        _AnimatedCard(
                          controller: _cardCtrls[3],
                          child: TextButton(
                            onPressed: isLoading ? null : () => _loginAs('client'),
                            child: const Text(
                              'כבר יש לי חשבון',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header widget
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66F59E0B),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'תורי',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'מה תרצה לעשות?',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Role card
// ---------------------------------------------------------------------------

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressAnim,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.slate900.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animation helpers
// ---------------------------------------------------------------------------

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({required this.controller, required this.child});
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, c) => FadeTransition(
        opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({required this.controller, required this.child});
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, c) => FadeTransition(
        opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
          child: c,
        ),
      ),
      child: child,
    );
  }
}
