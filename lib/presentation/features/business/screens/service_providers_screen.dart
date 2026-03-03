import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/business_provider.dart';

class ServiceProvidersScreen extends ConsumerWidget {
  const ServiceProvidersScreen({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppLoading();

    // Get the business first, then load SPs
    final businessAsync = ref.watch(businessProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        leading: scaffoldKey != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => scaffoldKey!.currentState?.openDrawer(),
              )
            : null,
        title: Text(context.l10n.serviceProviders),
      ),
      body: businessAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (business) => _SpListBody(
          businessId: business.id,
          ownerId: user.id,
        ),
      ),
      floatingActionButton: businessAsync.maybeWhen(
        data: (business) => FloatingActionButton.extended(
          onPressed: () => _showInviteDialog(context, ref, business.id),
          icon: const Icon(Icons.person_add_outlined),
          label: Text(context.l10n.inviteServiceProvider),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        orElse: () => null,
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    WidgetRef ref,
    String businessId,
  ) {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey   = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.inviteServiceProvider),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: context.l10n.name),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.validationRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: context.l10n.email),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.l10n.validationRequired;
                  }
                  if (!v.contains('@')) return context.l10n.validationEmail;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(ctx).pop();
              try {
                final client = ref.read(apiClientProvider);
                await client.post<void>(
                  '/businesses/$businessId/invite-sp',
                  data: {
                    'name':  nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                  },
                );
                if (context.mounted) {
                  context.showSnackBar(context.l10n.inviteSent);
                }
              } catch (_) {
                if (context.mounted) {
                  context.showSnackBar(context.l10n.error, isError: true);
                }
              }
            },
            child: Text(context.l10n.inviteServiceProvider),
          ),
        ],
      ),
    );
  }
}

// ── SP list body (separate widget to have businessId) ────────────────────────

class _SpListBody extends ConsumerWidget {
  const _SpListBody({required this.businessId, required this.ownerId});

  final String businessId;
  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spsAsync = ref.watch(serviceProvidersListProvider(businessId));

    return spsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(serviceProvidersListProvider(businessId)),
      ),
      data: (sps) => sps.isEmpty
          ? EmptyState(
              message: context.l10n.noServiceProviders,
              icon: Icons.engineering_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _SpCard(sp: sps[i]),
            ),
    );
  }
}

// ── SP card with bottom sheet on tap ─────────────────────────────────────────

class _SpCard extends StatelessWidget {
  const _SpCard({required this.sp});

  final SpBasicInfo sp;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: sp.profileImage != null
                      ? NetworkImage(sp.profileImage!)
                      : null,
                  child: sp.profileImage == null
                      ? Text(
                          '${sp.firstName[0]}${sp.lastName[0]}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sp.fullName, style: context.textTheme.titleMedium),
                      if (sp.specialty != null && sp.specialty!.isNotEmpty)
                        Text(
                          sp.specialty!,
                          style: context.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sp.isActive
                        ? AppColors.approvedBg
                        : AppColors.canceledBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    sp.isActive
                        ? context.l10n.active
                        : context.l10n.inactive,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: sp.isActive
                          ? AppColors.approvedText
                          : AppColors.canceledText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: sp.profileImage != null
                      ? NetworkImage(sp.profileImage!)
                      : null,
                  child: sp.profileImage == null
                      ? Text(
                          '${sp.firstName[0]}${sp.lastName[0]}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sp.fullName, style: ctx.textTheme.titleLarge),
                      if (sp.specialty != null && sp.specialty!.isNotEmpty)
                        Text(
                          sp.specialty!,
                          style: ctx.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Status info
            _DetailRow(
              icon: sp.isActive ? Icons.check_circle : Icons.cancel_outlined,
              color: sp.isActive ? AppColors.success : AppColors.textSecondary,
              label: sp.isActive
                  ? ctx.l10n.active
                  : ctx.l10n.inactive,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: context.textTheme.bodyMedium?.copyWith(color: color)),
        ],
      );
}
