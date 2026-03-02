import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _bgController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bgOpacity = CurvedAnimation(parent: _bgController, curve: Curves.easeIn);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('hasLaunched') ?? false;
    if (!mounted) return;

    if (!hasLaunched) {
      await prefs.setBool('hasLaunched', true);
      context.go('/onboarding');
    } else {
      await ref.read(authProvider.notifier).checkAuth();
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: FadeTransition(
        opacity: _bgOpacity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              stops: [0.0, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative ambient circles
              Positioned(
                top: -80,
                right: -60,
                child: _AmbientCircle(size: 280, opacity: 0.06),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _AmbientCircle(size: 320, opacity: 0.04),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo mark
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: _LogoMark(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // App name
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            Text(
                              'תורי',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ניהול תורים חכם',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom loading dots
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: const _LoadingDots(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.4),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.calendar_month_rounded,
          size: 52,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AmbientCircle extends StatelessWidget {
  const _AmbientCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF59E0B).withOpacity(opacity),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final bounce = offset < 0.5
                ? offset * 2
                : (1.0 - offset) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6 + bounce * 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B)
                    .withOpacity(0.3 + bounce * 0.7),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        );
      }),
    );
  }
}
