import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, this.icon, super.key});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 72,
                color: context.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
