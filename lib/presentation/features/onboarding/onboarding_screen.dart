import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late final List<AnimationController> _iconControllers;

  static const _slides = [
    _SlideData(
      icon: Icons.calendar_month_rounded,
      bgColor: Color(0xFF1E293B),
      accentColor: Color(0xFFF59E0B),
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      titleHe: 'קבע תור בשניות',
      bodyHe: 'מצא עסקים, בחר שירות\nותאם תור - הכל בכמה לחיצות',
      titleEn: 'Book in seconds',
    ),
    _SlideData(
      icon: Icons.store_rounded,
      bgColor: Color(0xFF0F172A),
      accentColor: Color(0xFF3B82F6),
      iconBgColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF1D4ED8),
      titleHe: 'נהל את העסק שלך',
      bodyHe: 'עקוב אחר תורים, לקוחות ונותני שירות\n- הכל במקום אחד',
      titleEn: 'Manage your business',
    ),
    _SlideData(
      icon: Icons.notifications_rounded,
      bgColor: Color(0xFF064E3B),
      accentColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFD1FAE5),
      iconColor: Color(0xFF065F46),
      titleHe: 'תישאר מעודכן',
      bodyHe: 'קבל תזכורות על תורים\nוחדשות מהעסקים שלך',
      titleEn: 'Stay updated',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconControllers = List.generate(
      _slides.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      ),
    );
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _iconControllers[page].forward(from: 0);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLaunched', true);
    if (mounted) context.go('/welcome');
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: slide.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: slide.bgColor,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'דלג',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 15,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) {
                    return _SlideContent(
                      data: _slides[i],
                      controller: _iconControllers[i],
                    );
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? slide.accentColor
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: slide.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'בוא נתחיל!'
                              : 'הבא',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.data, required this.controller});
  final _SlideData data;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );
    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: controller,
            builder: (_, child) => ScaleTransition(
              scale: scaleAnim,
              child: FadeTransition(
                opacity: fadeAnim,
                child: child,
              ),
            ),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: data.iconBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: data.accentColor.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 72,
                color: data.iconColor,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            data.titleHe,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Body
          Text(
            data.bodyHe,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white60,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.bgColor,
    required this.accentColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.titleHe,
    required this.bodyHe,
    required this.titleEn,
  });

  final IconData icon;
  final Color bgColor;
  final Color accentColor;
  final Color iconBgColor;
  final Color iconColor;
  final String titleHe;
  final String bodyHe;
  final String titleEn;
}
