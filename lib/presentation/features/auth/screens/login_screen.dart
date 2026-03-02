import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthError) {
        context.showSnackBar(next.message, isError: true);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo / Title
              Icon(Icons.calendar_month_rounded, size: 72, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                context.l10n.appName,
                style: context.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Appointment Scheduling',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (isLoading)
                const CircularProgressIndicator()
              else ...[
                _GoogleSignInButton(
                  label: context.l10n.continueAsClient,
                  onTap: () => ref.read(authProvider.notifier).loginWithGoogle(
                        role: 'client',
                      ),
                ),
                const SizedBox(height: 12),
                _GoogleSignInButton(
                  label: context.l10n.continueAsBusiness,
                  isPrimary: false,
                  onTap: () => _showBusinessNameDialog(context, ref),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBusinessNameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.businessName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.l10n.businessName,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await ref.read(authProvider.notifier).loginWithGoogle(
            role: 'businessOwner',
            businessName: controller.text.trim(),
          );
    }
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: isPrimary
            ? ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.login, size: 20),
                label: Text(label),
              )
            : OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.business, size: 20),
                label: Text(label),
              ),
      );
}
