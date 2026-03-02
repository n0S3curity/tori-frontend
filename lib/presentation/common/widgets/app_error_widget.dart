import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.retry),
                ),
              ],
            ],
          ),
        ),
      );
}
