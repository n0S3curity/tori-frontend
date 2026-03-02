import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/service_entity.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/services_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppLoading();

    final servicesAsync = ref.watch(servicesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myServices),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/services/create'),
            tooltip: context.l10n.addService,
          ),
        ],
      ),
      body: servicesAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(servicesProvider(user.id)),
        ),
        data: (services) => services.isEmpty
            ? EmptyState(
                message: context.l10n.noData,
                icon: Icons.design_services_outlined,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _ServiceCard(service: services[i]),
              ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/services/${service.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.design_services_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: context.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${AppFormatters.formatCurrency(service.price)} · ${AppFormatters.formatDuration(service.durationMinutes)}',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      );
}
