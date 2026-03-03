import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../common/widgets/app_drawer.dart';
import '../../appointments/screens/appointments_screen.dart';
import '../../business/screens/business_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../auth/providers/auth_provider.dart';

/// A key shared with tab screens so they can open the HomeScreen's drawer.
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  List<_TabConfig> _buildTabs(BuildContext context, String role) {
    final l10n = context.l10n;
    final all = [
      _TabConfig(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: l10n.appointments,
        route: '/home',
        screen: AppointmentsScreen(scaffoldKey: role != AppRoles.client ? homeScaffoldKey : null),
        roles: [AppRoles.client, AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _TabConfig(
        icon: Icons.design_services_outlined,
        activeIcon: Icons.design_services_rounded,
        label: l10n.services,
        route: '/services',
        screen: ServicesScreen(scaffoldKey: homeScaffoldKey),
        roles: [AppRoles.serviceProvider, AppRoles.businessOwner],
      ),
      _TabConfig(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: l10n.stats,
        route: '/stats',
        screen: StatsScreen(scaffoldKey: homeScaffoldKey),
        roles: [AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _TabConfig(
        icon: Icons.business_outlined,
        activeIcon: Icons.business_rounded,
        label: l10n.business,
        route: '/business',
        screen: BusinessScreen(scaffoldKey: homeScaffoldKey),
        roles: [AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _TabConfig(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.profile,
        route: '/profile',
        screen: ProfileScreen(scaffoldKey: role != AppRoles.client ? homeScaffoldKey : null),
        roles: [AppRoles.client, AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
    ];
    return all.where((t) => t.roles.contains(role)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider) ?? AppRoles.client;
    final tabs = _buildTabs(context, role);
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    // SP, BO, CO get a sidebar drawer; clients use only bottom nav
    final showDrawer = role != AppRoles.client;

    return Scaffold(
      key: homeScaffoldKey,
      drawer: showDrawer ? AppDrawer(activeRoute: tabs[safeIndex].route) : null,
      body: tabs[safeIndex].screen,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: tabs
              .map(
                (t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.screen,
    required this.roles,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final Widget screen;
  final List<String> roles;
}
