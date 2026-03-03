import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/business_entity.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/business_provider.dart';

class AdminBusinessDetailScreen extends ConsumerWidget {
  const AdminBusinessDetailScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: businessAsync.maybeWhen(
          data: (b) => Text(b.name),
          orElse: () => Text(context.l10n.businessInfo),
        ),
      ),
      body: businessAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(businessProvider(businessId)),
        ),
        data: (business) => _BusinessDetailBody(business: business),
      ),
    );
  }
}

// ── Main body (stateful for loading overlay) ──────────────────────────────────

class _BusinessDetailBody extends ConsumerStatefulWidget {
  const _BusinessDetailBody({required this.business});

  final BusinessEntity business;

  @override
  ConsumerState<_BusinessDetailBody> createState() => _BusinessDetailBodyState();
}

class _BusinessDetailBodyState extends ConsumerState<_BusinessDetailBody> {
  bool _loading = false;

  // ── API helpers ─────────────────────────────────────────────────────────────

  Future<void> _disableBusiness() async {
    if (!await _confirmAction(context.l10n.disableBusiness)) return;
    await _run(() async {
      final client = ref.read(apiClientProvider);
      await client.put<void>('/businesses/${widget.business.id}/disable');
      ref.invalidate(businessProvider(widget.business.id));
    });
  }

  Future<void> _disableUsers() async {
    if (!await _confirmAction(context.l10n.disableUsers)) return;
    await _run(() async {
      final client = ref.read(apiClientProvider);
      await client.put<void>('/businesses/${widget.business.id}/users-disable');
      ref.invalidate(businessProvider(widget.business.id));
    });
  }

  Future<void> _toggleReminders({required bool enabled}) async {
    await _run(() async {
      final client = ref.read(apiClientProvider);
      await client.put<void>(
        '/businesses/${widget.business.id}/reminders',
        data: {'remindersEnabled': enabled},
      );
      ref.invalidate(businessProvider(widget.business.id));
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) context.showSnackBar(context.l10n.success);
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10n.error, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirmAction(String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(context.l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.canceledText,
            ),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final b = widget.business;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Business info card ────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Logo avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage:
                          b.logo != null ? NetworkImage(b.logo!) : null,
                      child: b.logo == null
                          ? Text(
                              b.name[0].toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.name,
                            style: context.textTheme.titleLarge,
                          ),
                          if (b.formattedAddress != null)
                            Text(
                              b.formattedAddress!,
                              style: context.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: b.isDisabled
                            ? AppColors.canceledBg
                            : AppColors.approvedBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        b.isDisabled
                            ? context.l10n.inactive
                            : context.l10n.active,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: b.isDisabled
                              ? AppColors.canceledText
                              : AppColors.approvedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Admin actions section ─────────────────────────────────────
            Text(
              context.l10n.adminActions,
              style: context.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  // Disable business toggle
                  SwitchListTile(
                    value: b.isDisabled,
                    onChanged: _loading || b.isDisabled
                        ? null
                        : (_) => _disableBusiness(),
                    activeColor: AppColors.canceledText,
                    secondary: Icon(
                      b.isDisabled
                          ? Icons.store_mall_directory_outlined
                          : Icons.store_outlined,
                      color: b.isDisabled
                          ? AppColors.canceledText
                          : AppColors.textSecondary,
                    ),
                    title: Text(context.l10n.disableBusiness),
                    subtitle: b.isDisabled
                        ? Text(
                            context.l10n.inactive,
                            style: TextStyle(color: AppColors.canceledText),
                          )
                        : null,
                  ),
                  const Divider(height: 1, indent: 16),

                  // Disable users toggle
                  SwitchListTile(
                    value: b.usersDisabled,
                    onChanged: _loading || b.usersDisabled
                        ? null
                        : (_) => _disableUsers(),
                    activeColor: AppColors.canceledText,
                    secondary: Icon(
                      b.usersDisabled
                          ? Icons.people_alt_outlined
                          : Icons.people_outline,
                      color: b.usersDisabled
                          ? AppColors.canceledText
                          : AppColors.textSecondary,
                    ),
                    title: Text(context.l10n.disableUsers),
                    subtitle: b.usersDisabled
                        ? Text(
                            context.l10n.inactive,
                            style: TextStyle(color: AppColors.canceledText),
                          )
                        : null,
                  ),
                  const Divider(height: 1, indent: 16),

                  // Reminders toggle (can go both ways)
                  SwitchListTile(
                    value: b.remindersEnabled,
                    onChanged: _loading
                        ? null
                        : (v) => _toggleReminders(enabled: v),
                    activeColor: AppColors.primary,
                    secondary: Icon(
                      b.remindersEnabled
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      color: b.remindersEnabled
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(context.l10n.remindersEnabled),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Service providers section ─────────────────────────────────
            Text(
              context.l10n.serviceProviders,
              style: context.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (ctx, ref2, _) {
                final spsAsync =
                    ref2.watch(serviceProvidersListProvider(b.id));
                return spsAsync.when(
                  loading: () => const AppLoading(),
                  error: (e, _) => AppErrorWidget(message: e.toString()),
                  data: (sps) => sps.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              context.l10n.noServiceProviders,
                              style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      : Column(
                          children: sps.map((sp) {
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1),
                                  backgroundImage: sp.profileImage != null
                                      ? NetworkImage(sp.profileImage!)
                                      : null,
                                  child: sp.profileImage == null
                                      ? Text(
                                          '${sp.firstName[0]}${sp.lastName[0]}',
                                          style: TextStyle(
                                              color: AppColors.primary),
                                        )
                                      : null,
                                ),
                                title: Text(sp.fullName),
                                subtitle: sp.specialty != null
                                    ? Text(sp.specialty!)
                                    : null,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
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
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                      color: sp.isActive
                                          ? AppColors.approvedText
                                          : AppColors.canceledText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),

        // Loading overlay
        if (_loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x55000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
