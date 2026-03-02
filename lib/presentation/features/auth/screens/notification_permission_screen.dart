import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/remote/notifications_remote_datasource.dart';
import '../providers/auth_provider.dart';

class NotificationPermissionScreen extends ConsumerWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Icons.notifications_active_rounded,
                  size: 96,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.notificationPermissionTitle,
                  style: context.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.notificationPermissionBody,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _requestPermission(context, ref),
                  child: const Text('Allow Notifications'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final apiClient = ref.read(apiClientProvider);
        final ds = NotificationsRemoteDataSource(apiClient);
        await ds.updateFcmToken(token);
        await ref.read(secureStorageProvider).saveFcmToken(token);
      }
      if (context.mounted) context.go('/home');
    } else {
      if (context.mounted) {
        context.showSnackBar(context.l10n.notificationPermissionBody, isError: true);
      }
    }
  }
}
