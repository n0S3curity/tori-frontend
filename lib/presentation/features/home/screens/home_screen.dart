import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../common/widgets/app_drawer.dart';
import '../../appointments/screens/appointments_screen.dart';
import '../../business/screens/business_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  List<_TabConfig> _buildTabs(String role) {
    final all = [
      _TabConfig(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: 'Appointments',
        screen: const AppointmentsScreen(),
        roles: [AppRoles.client, AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _TabConfig(
        icon: Icons.design_services_outlined,
        activeIcon: Icons.design_services_rounded,
        label: 'Services',
        screen: const ServicesScreen(),
        roles: [AppRoles.serviceProvider, AppRoles.businessOwner],
      ),
      _TabConfig(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: 'Stats',
        screen: const StatsScreen(),
        roles: [AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _TabConfig(
        icon: Icons.business_outlined,
        activeIcon: Icons.business_rounded,
        label: 'Business',
        screen: const BusinessScreen(),
        roles: [AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _TabConfig(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        screen: const ProfileScreen(),
        roles: [AppRoles.client, AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
    ];
    return all.where((t) => t.roles.contains(role)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider) ?? AppRoles.client;
    final tabs = _buildTabs(role);
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    // SP, BO, CO get a sidebar drawer; clients use only bottom nav
    final showDrawer = role != AppRoles.client;

    return Scaffold(
      drawer: showDrawer ? const AppDrawer() : null,
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
    required this.screen,
    required this.roles,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;
  final List<String> roles;
}
