import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../providers/business_provider.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.clients),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.pending),
            Tab(text: context.l10n.approved),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingTab(businessId: widget.businessId),
          _ApprovedTab(businessId: widget.businessId),
        ],
      ),
    );
  }
}

// ─── Pending Registrations Tab ────────────────────────────────────────────────

class _PendingTab extends ConsumerWidget {
  const _PendingTab({required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRegistrationsProvider(businessId));

    return pendingAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(pendingRegistrationsProvider(businessId)),
      ),
      data: (users) => users.isEmpty
          ? EmptyState(
              message: context.l10n.noClients,
              icon: Icons.people_outline,
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(pendingRegistrationsProvider(businessId).future),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _PendingClientCard(
                  user: users[i],
                  businessId: businessId,
                  onAction: () {
                    ref.invalidate(pendingRegistrationsProvider(businessId));
                    ref.invalidate(approvedClientsProvider(businessId));
                  },
                ),
              ),
            ),
    );
  }
}

class _PendingClientCard extends ConsumerWidget {
  const _PendingClientCard({
    required this.user,
    required this.businessId,
    required this.onAction,
  });

  final UserEntity user;
  final String businessId;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: const TextStyle(color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: context.textTheme.titleSmall),
                    Text(user.email, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: AppColors.success),
                    tooltip: context.l10n.approve,
                    onPressed: () => _onApprove(context, ref),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_outlined,
                        color: context.colorScheme.error),
                    tooltip: context.l10n.reject,
                    onPressed: () => _onReject(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Future<void> _onApprove(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.approve,
      body: '${context.l10n.approve} ${user.fullName}?',
    );
    if (confirmed != true) return;
    final ds = ref.read(businessesRemoteDsProvider);
    await ds.approveRegistration(businessId, user.id);
    onAction();
  }

  Future<void> _onReject(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.reject,
      body: '${context.l10n.reject} ${user.fullName}?',
      isDestructive: true,
    );
    if (confirmed != true) return;
    final ds = ref.read(businessesRemoteDsProvider);
    await ds.rejectRegistration(businessId, user.id);
    onAction();
  }
}

// ─── Approved Clients Tab ─────────────────────────────────────────────────────

class _ApprovedTab extends ConsumerWidget {
  const _ApprovedTab({required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvedAsync = ref.watch(approvedClientsProvider(businessId));

    return approvedAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(approvedClientsProvider(businessId)),
      ),
      data: (users) => users.isEmpty
          ? EmptyState(
              message: context.l10n.noClients,
              icon: Icons.people_outline,
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(approvedClientsProvider(businessId).future),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _ApprovedClientCard(user: users[i]),
              ),
            ),
    );
  }
}

class _ApprovedClientCard extends StatelessWidget {
  const _ApprovedClientCard({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.successLight,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: const TextStyle(color: AppColors.successDark),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: context.textTheme.titleSmall),
                    Text(user.email, style: context.textTheme.bodySmall),
                    if (user.phone != null)
                      Text(user.phone!, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 20),
            ],
          ),
        ),
      );
}
