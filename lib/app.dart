import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/features/auth/providers/auth_provider.dart';
import 'presentation/features/auth/screens/login_screen.dart';
import 'presentation/features/auth/screens/notification_permission_screen.dart';
import 'presentation/features/auth/screens/otp_screen.dart';
import 'presentation/features/appointments/screens/appointments_screen.dart';
import 'presentation/features/appointments/screens/book_appointment_screen.dart';
import 'presentation/features/home/screens/home_screen.dart';
import 'presentation/features/services/screens/services_screen.dart';
import 'presentation/features/stats/screens/stats_screen.dart';
import 'presentation/features/business/screens/business_screen.dart';
import 'presentation/features/business/screens/clients_screen.dart';
import 'presentation/features/appointments/screens/appointment_detail_screen.dart';
import 'presentation/features/profile/screens/profile_screen.dart';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final _routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.uri.path;

      // While checkAuth() is still running, stay on splash.
      if (authState is AuthInitial || authState is AuthLoading) {
        return path == '/splash' ? null : '/splash';
      }

      // Not authenticated → login
      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (path.startsWith('/auth')) return null;
        return '/auth/login';
      }

      // Authenticated
      if (authState is AuthAuthenticated) {
        final user = authState.user;

        // Must verify phone first
        if (!user.phoneVerified && path != '/auth/otp-verify') {
          return '/auth/otp-verify';
        }

        // Navigate away from splash / login once authenticated
        if (path == '/splash' || path == '/auth/login') {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/otp-verify', builder: (_, __) => const OtpScreen()),
      GoRoute(
        path: '/auth/notification-permission',
        builder: (_, __) => const NotificationPermissionScreen(),
      ),
      ShellRoute(
        builder: (ctx, state, child) => child,
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (_, __) => const AppointmentsScreen(),
            routes: [
              GoRoute(
                path: 'book',
                builder: (_, __) => const BookAppointmentScreen(),
              ),
              GoRoute(
                path: ':appointmentId',
                builder: (_, state) => AppointmentDetailScreen(
                  appointmentId: state.pathParameters['appointmentId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/services',
            builder: (_, __) => const ServicesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const _ComingSoon(title: 'Create Service'),
              ),
              GoRoute(
                path: ':serviceId',
                builder: (_, state) =>
                    _ComingSoon(title: 'Service ${state.pathParameters['serviceId']}'),
              ),
            ],
          ),
          GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
          GoRoute(path: '/business', builder: (_, __) => const BusinessScreen()),
          GoRoute(
            path: '/business/clients/:businessId',
            builder: (_, state) => ClientsScreen(
              businessId: state.pathParameters['businessId']!,
            ),
          ),
          GoRoute(
            path: '/business/service-providers',
            builder: (_, __) => const _ComingSoon(title: 'Service Providers'),
          ),
          GoRoute(
            path: '/business/settings',
            builder: (_, __) => const _ComingSoon(title: 'Business Settings'),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/admin/businesses/:businessId',
            builder: (_, state) =>
                _ComingSoon(title: 'Business ${state.pathParameters['businessId']}'),
          ),
        ],
      ),
    ],
  );
});

// Notifier to trigger GoRouter redirect when auth state changes
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

// ---------------------------------------------------------------------------
// App widget
// ---------------------------------------------------------------------------

class ToriApp extends ConsumerWidget {
  const ToriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final language = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Tori',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: Locale(language),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('he'), Locale('en')],
      builder: (context, child) => Directionality(
        textDirection: language == 'he' ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Run checkAuth exactly once, after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text('$title — Coming soon', style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
}
