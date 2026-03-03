import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/business_provider.dart';

class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppLoading();

    // For CO: show all businesses list
    if (user.isCompanyOwner) return _AdminBusinessList(scaffoldKey: scaffoldKey);

    // For BO: show own business management
    return _OwnerBusinessPanel(scaffoldKey: scaffoldKey);
  }
}

class _OwnerBusinessPanel extends ConsumerWidget {
  const _OwnerBusinessPanel({this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final businessAsync = ref.watch(businessProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        leading: scaffoldKey != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => scaffoldKey!.currentState?.openDrawer(),
              )
            : null,
        title: Text(context.l10n.business),
      ),
      body: businessAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (business) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Business info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (business.logo != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(business.logo!, width: 48, height: 48, fit: BoxFit.cover),
                          )
                        else
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.business, color: AppColors.primary),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(business.name, style: context.textTheme.titleLarge),
                              if (business.formattedAddress != null)
                                Text(business.formattedAddress!, style: context.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            _MenuCard(
              icon: Icons.people_outline,
              title: context.l10n.clients,
              subtitle: context.l10n.manageClients,
              onTap: () => context.push('/business/clients/${business.id}'),
            ),
            const SizedBox(height: 8),
            _MenuCard(
              icon: Icons.engineering_outlined,
              title: context.l10n.serviceProviders,
              subtitle: context.l10n.manageProviders,
              onTap: () => context.push('/business/service-providers'),
            ),
            const SizedBox(height: 8),
            _MenuCard(
              icon: Icons.settings_outlined,
              title: context.l10n.businessSettings,
              subtitle: context.l10n.manageBusinessSettings,
              onTap: () => context.push('/business/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBusinessList extends ConsumerWidget {
  const _AdminBusinessList({this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: scaffoldKey != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => scaffoldKey!.currentState?.openDrawer(),
              )
            : null,
        title: Text(context.l10n.allBusinesses),
      ),
      body: businessesAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (businesses) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: businesses.length,
          itemBuilder: (ctx, i) {
            final b = businesses[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: Text(b.name),
                subtitle: b.formattedAddress != null ? Text(b.formattedAddress!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (b.isDisabled)
                      const Icon(Icons.block, color: AppColors.error, size: 16),
                    if (b.usersDisabled)
                      const Icon(Icons.person_off, color: AppColors.warning, size: 16),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => context.push('/admin/businesses/${b.id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Amber icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      );
}
