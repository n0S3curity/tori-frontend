import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final role = user.role;
    final navItems = _navItemsForRole(role);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _DrawerHeader(user: user),
            const Divider(height: 1),

            // ── Navigation items (mirror bottom nav) ─────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ...navItems.map(
                    (item) => _DrawerNavTile(
                      icon: item.icon,
                      label: item.label(context),
                      route: item.route,
                    ),
                  ),

                  const Divider(height: 24, indent: 20, endIndent: 20),

                  // ── Invite (SP → clients only, BO → clients + SPs) ───────
                  if (role == AppRoles.serviceProvider)
                    _DrawerNavTile(
                      icon: Icons.qr_code_rounded,
                      label: context.l10n.inviteClient,
                      route: '/qr-invite',
                    ),
                  if (role == AppRoles.businessOwner)
                    _DrawerNavTile(
                      icon: Icons.qr_code_rounded,
                      label: context.l10n.inviteMembers,
                      route: '/qr-invite',
                    ),

                  const Divider(height: 24, indent: 20, endIndent: 20),

                  // ── Extras ──────────────────────────────────────────────
                  _DrawerActionTile(
                    icon: Icons.info_outline_rounded,
                    label: context.l10n.about,
                    onTap: () => _showAbout(context),
                  ),

                  // ── Logout ──────────────────────────────────────────────
                  _DrawerActionTile(
                    icon: Icons.logout_rounded,
                    label: context.l10n.logout,
                    color: AppColors.error,
                    onTap: () => _logout(context, ref),
                  ),
                ],
              ),
            ),

            // ── Footer: app version ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Tori v1.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Role → nav items ────────────────────────────────────────────────────

  List<_NavItem> _navItemsForRole(String role) {
    final all = [
      _NavItem(
        icon: Icons.calendar_today_rounded,
        label: (ctx) => ctx.l10n.myAppointments,
        route: '/home',
        roles: [
          AppRoles.client,
          AppRoles.serviceProvider,
          AppRoles.businessOwner,
          AppRoles.companyOwner,
        ],
      ),
      _NavItem(
        icon: Icons.design_services_rounded,
        label: (ctx) => ctx.l10n.myServices,
        route: '/services',
        roles: [AppRoles.serviceProvider, AppRoles.businessOwner],
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        label: (ctx) => ctx.l10n.stats,
        route: '/stats',
        roles: [AppRoles.serviceProvider, AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _NavItem(
        icon: Icons.business_rounded,
        label: (ctx) => ctx.l10n.business,
        route: '/business',
        roles: [AppRoles.businessOwner, AppRoles.companyOwner],
      ),
      _NavItem(
        icon: Icons.person_rounded,
        label: (ctx) => ctx.l10n.profile,
        route: '/profile',
        roles: [
          AppRoles.client,
          AppRoles.serviceProvider,
          AppRoles.businessOwner,
          AppRoles.companyOwner,
        ],
      ),
    ];
    return all.where((item) => item.roles.contains(role)).toList();
  }

  // ── Actions ────────────────────────────────────────────────────────────

  void _showAbout(BuildContext context) {
    Navigator.of(context).pop();
    showAboutDialog(
      context: context,
      applicationName: 'Tori',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Tori. All rights reserved.',
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.logout,
      body: 'Are you sure you want to log out?',
      isDestructive: true,
    );
    if (confirmed == true) {
      ref.read(authProvider.notifier).logout();
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user});

  final dynamic user; // UserEntity

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage:
                user.profileImage != null ? NetworkImage(user.profileImage!) : null,
            child: user.profileImage == null
                ? Text(
                    '${user.firstName[0]}${user.lastName[0]}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // Name + email + role badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    _roleLabel(user.role, context),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role, BuildContext context) {
    switch (role) {
      case AppRoles.serviceProvider:
        return context.l10n.roleServiceProvider;
      case AppRoles.businessOwner:
        return context.l10n.roleBusinessOwner;
      case AppRoles.companyOwner:
        return context.l10n.roleCompanyOwner;
      default:
        return context.l10n.roleClient;
    }
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        context.go(route);
      },
    );
  }
}

class _DrawerActionTile extends StatelessWidget {
  const _DrawerActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: c,
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: onTap,
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.roles,
  });

  final IconData icon;
  final String Function(BuildContext) label;
  final String route;
  final List<String> roles;
}
