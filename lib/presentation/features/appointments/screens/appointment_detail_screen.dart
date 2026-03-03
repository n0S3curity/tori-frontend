import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../common/widgets/status_chip.dart';
import '../providers/appointments_provider.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(appointmentDetailProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appointmentDetails)),
      body: detailAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(appointmentDetailProvider(appointmentId)),
        ),
        data: (appointment) => _DetailBody(appointment: appointment),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + service header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    appointment.serviceName.isNotEmpty
                        ? appointment.serviceName
                        : context.l10n.myAppointments,
                    style: context.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  StatusChip(status: appointment.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: context.l10n.date,
                    value: AppFormatters.formatDate(appointment.scheduledAt),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: context.l10n.time,
                    value: AppFormatters.formatTime(appointment.scheduledAt),
                  ),
                  if (appointment.clientName.isNotEmpty) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.person_rounded,
                      label: context.l10n.roleClient,
                      value: appointment.clientName,
                    ),
                  ],
                  if (appointment.spName.isNotEmpty) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.engineering_rounded,
                      label: context.l10n.provider,
                      value: appointment.spName,
                    ),
                  ],
                  if (appointment.servicePrice != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.payments_rounded,
                      label: context.l10n.price,
                      value: AppFormatters.formatCurrency(appointment.servicePrice!),
                      valueColor: AppColors.success,
                    ),
                  ],
                  if (appointment.notes.isNotEmpty) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.notes_rounded,
                      label: context.l10n.notes,
                      value: appointment.notes,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Cancel button
          if (!appointment.isCanceled && appointment.isUpcoming)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: Text(context.l10n.cancelAppointment),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.error,
                  side: BorderSide(color: context.colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmCancel(context, ref),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.cancelAppointment,
      body: context.l10n.cancelAppointmentConfirm,
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(appointmentsProvider.notifier).cancelAppointment(appointment.id);
      ref.invalidate(appointmentDetailProvider(appointment.id));
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: context.textTheme.titleSmall?.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
}
