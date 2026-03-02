import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  backgroundImage:
                      user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                  child: user.profileImage == null
                      ? Text(
                          '${user.firstName[0]}${user.lastName[0]}',
                          style: context.textTheme.headlineMedium
                              ?.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user.fullName, style: context.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(user.email, style: context.textTheme.bodySmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role,
                    style: context.textTheme.labelLarge?.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),

          // Language toggle
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'he', label: Text(context.l10n.hebrew)),
                ButtonSegment(value: 'en', label: Text(context.l10n.english)),
              ],
              selected: {language},
              onSelectionChanged: (s) =>
                  ref.read(languageProvider.notifier).setLanguage(s.first),
            ),
          ),

          // Phone status
          ListTile(
            leading: Icon(
              user.phoneVerified ? Icons.verified : Icons.phone,
              color: user.phoneVerified ? AppColors.success : null,
            ),
            title: Text(context.l10n.phone),
            subtitle: Text(user.phone ?? 'Not set'),
            trailing: user.phoneVerified
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 18)
                : null,
          ),

          const Divider(),
          const SizedBox(height: 8),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: context.colorScheme.error),
            title: Text(
              context.l10n.logout,
              style: TextStyle(color: context.colorScheme.error),
            ),
            onTap: () async {
              final confirmed = await context.showConfirmDialog(
                title: context.l10n.logout,
                body: 'Are you sure you want to log out?',
                isDestructive: true,
              );
              if (confirmed == true) {
                ref.read(authProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
