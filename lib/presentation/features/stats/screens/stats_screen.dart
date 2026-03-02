import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/stats_model.dart';
import '../../../common/widgets/app_error_widget.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final period = ref.watch(selectedPeriodProvider);
    if (user == null) return const AppLoading();

    final isBO = user.isBusinessOwner || user.isCompanyOwner;
    final params = StatsParams(id: user.id, period: period, isBusinessStats: isBO);
    final statsAsync = ref.watch(statsProvider(params));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.stats)),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'daily', label: Text(context.l10n.daily)),
                ButtonSegment(value: 'monthly', label: Text(context.l10n.monthly)),
                ButtonSegment(value: 'yearly', label: Text(context.l10n.yearly)),
              ],
              selected: {period},
              onSelectionChanged: (s) =>
                  ref.read(selectedPeriodProvider.notifier).state = s.first,
            ),
          ),
          Expanded(
            child: statsAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(statsProvider(params)),
              ),
              data: (stats) => _StatsContent(stats: stats),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});

  final StatsModel stats;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available,
                    label: context.l10n.totalAppointments,
                    value: stats.totalAppointments.toString(),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    label: context.l10n.totalRevenue,
                    value: AppFormatters.formatCurrency(stats.totalBenefit),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule,
                    label: context.l10n.workingHours,
                    value: '${stats.actualWorkingHours}h',
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel_outlined,
                    label: context.l10n.cancellationRate,
                    value: AppFormatters.formatPercent(stats.cancellationRate),
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            if (stats.newClientsCount != null) ...[
              const SizedBox(height: 12),
              _StatCard(
                icon: Icons.person_add_alt_1,
                label: context.l10n.newClients,
                value: stats.newClientsCount.toString(),
                color: AppColors.secondary,
              ),
            ],
            const SizedBox(height: 24),
            // Bar chart — completed vs canceled
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _bar(0, stats.completedAppointments.toDouble(), AppColors.success),
                    _bar(1, stats.canceledAppointments.toDouble(), AppColors.error),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          v == 0 ? 'Completed' : 'Canceled',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles()),
                    rightTitles: const AxisTitles(sideTitles: SideTitles()),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      );

  BarChartGroupData _bar(int x, double y, Color color) => BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(toY: y, color: color, width: 40, borderRadius: BorderRadius.circular(4)),
        ],
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: context.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: context.textTheme.headlineSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      );
}
