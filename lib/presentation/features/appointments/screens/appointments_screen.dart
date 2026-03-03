import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/status_chip.dart';
import '../providers/appointments_provider.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: scaffoldKey != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => scaffoldKey!.currentState?.openDrawer(),
              )
            : null,
        title: Text(context.l10n.myAppointments),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/appointments/book'),
            tooltip: context.l10n.bookAppointment,
          ),
        ],
      ),
      body: appointmentsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(appointmentsProvider),
        ),
        data: (appointments) => appointments.isEmpty
            ? EmptyState(
                message: context.l10n.noData,
                icon: Icons.calendar_today_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(appointmentsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      _AppointmentCard(appointment: appointments[i]),
                ),
              ),
      ),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/appointments/${appointment.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appointment.serviceName.isNotEmpty
                            ? appointment.serviceName
                            : 'Appointment',
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                    StatusChip(status: appointment.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.formatDateTime(appointment.scheduledAt),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (appointment.clientName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14),
                      const SizedBox(width: 6),
                      Text(appointment.clientName, style: context.textTheme.bodySmall),
                    ],
                  ),
                ],
                if (!appointment.isCanceled && appointment.isUpcoming) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: Text(context.l10n.cancelAppointment),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colorScheme.error,
                      ),
                      onPressed: () => _confirmCancel(context, ref),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.cancelAppointment,
      body: context.l10n.cancelAppointmentConfirm,
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(appointmentsProvider.notifier).cancelAppointment(appointment.id);
    }
  }
}
