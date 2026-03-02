import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/entities/business_entity.dart';
import '../../../../domain/entities/service_entity.dart';
import '../../../common/widgets/app_loading.dart';
import '../../../features/business/providers/business_provider.dart';
import '../../../features/services/providers/services_provider.dart';
import '../providers/appointments_provider.dart';

// ─── Steps ────────────────────────────────────────────────────────────────────
enum _BookStep {
  selectService,  // Step 1
  selectProvider, // Step 2
  selectDateTime, // Step 3
  confirm,        // Step 4
}

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  _BookStep _step = _BookStep.selectService;

  BusinessEntity? _selectedBusiness;
  ServiceEntity? _selectedService;
  SpBasicInfo? _selectedSp;
  bool _anyProvider = false;
  DateTime? _selectedDateTime;
  bool _booking = false;

  int get _stepNumber => _step.index + 1;
  int get _totalSteps => _BookStep.values.length;

  String _stepTitle(BuildContext context) {
    switch (_step) {
      case _BookStep.selectService:
        return context.l10n.chooseService;
      case _BookStep.selectProvider:
        return context.l10n.chooseProvider;
      case _BookStep.selectDateTime:
        return context.l10n.chooseDateTime;
      case _BookStep.confirm:
        return context.l10n.confirmBooking;
    }
  }

  void _goBack() {
    if (_step.index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step = _BookStep.values[_step.index - 1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _BookingHeader(
              title: _stepTitle(context),
              step: _stepNumber,
              total: _totalSteps,
              onBack: _goBack,
            ),
            Expanded(child: _buildStepBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case _BookStep.selectService:
        return _SelectServiceStep(
          selectedBusiness: _selectedBusiness,
          selectedService: _selectedService,
          onBusinessSelected: (b) => setState(() {
            _selectedBusiness = b;
            _selectedService = null;
            _selectedSp = null;
            _selectedDateTime = null;
          }),
          onServiceSelected: (s) => setState(() {
            _selectedService = s;
          }),
          onNext: () => setState(() => _step = _BookStep.selectProvider),
        );

      case _BookStep.selectProvider:
        if (_selectedBusiness == null) return const SizedBox.shrink();
        return _SelectProviderStep(
          businessId: _selectedBusiness!.id,
          selectedSp: _selectedSp,
          anyProvider: _anyProvider,
          onSpSelected: (sp) => setState(() {
            _selectedSp = sp;
            _anyProvider = false;
          }),
          onAnySelected: () => setState(() {
            _selectedSp = null;
            _anyProvider = true;
          }),
          onNext: () => setState(() => _step = _BookStep.selectDateTime),
        );

      case _BookStep.selectDateTime:
        return _SelectDateTimeStep(
          selectedDateTime: _selectedDateTime,
          onPick: _pickDateTime,
          onNext: () => setState(() => _step = _BookStep.confirm),
        );

      case _BookStep.confirm:
        return _ConfirmStep(
          service: _selectedService,
          sp: _selectedSp,
          anyProvider: _anyProvider,
          dateTime: _selectedDateTime,
          booking: _booking,
          onConfirm: _book,
        );
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _book() async {
    if (_selectedService == null || _selectedDateTime == null) return;
    setState(() => _booking = true);

    final spId = (_anyProvider || _selectedSp == null)
        ? _selectedService!.serviceProviderId
        : _selectedSp!.spId;

    await ref.read(bookingProvider.notifier).book(
          serviceProviderId: spId,
          serviceId: _selectedService!.id,
          scheduledAt: _selectedDateTime!,
        );

    if (!mounted) return;
    setState(() => _booking = false);

    final bookState = ref.read(bookingProvider);
    if (bookState is AsyncData<AppointmentEntity?> && bookState.value != null) {
      ref.read(bookingProvider.notifier).reset();
      ref.invalidate(appointmentsProvider);
      context.go('/appointments');
    } else if (bookState is AsyncError) {
      context.showSnackBar(bookState.error.toString(), isError: true);
    }
  }
}

// ─── Frosted header with progress ─────────────────────────────────────────────

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({
    required this.title,
    required this.step,
    required this.total,
    required this.onBack,
  });

  final String title;
  final int step;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.step(step, total),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.1,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _CircleIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: step / total,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      );
}

// ─── Step 1: Select Service ───────────────────────────────────────────────────

class _SelectServiceStep extends ConsumerWidget {
  const _SelectServiceStep({
    required this.selectedBusiness,
    required this.selectedService,
    required this.onBusinessSelected,
    required this.onServiceSelected,
    required this.onNext,
  });

  final BusinessEntity? selectedBusiness;
  final ServiceEntity? selectedService;
  final ValueChanged<BusinessEntity> onBusinessSelected;
  final ValueChanged<ServiceEntity> onServiceSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesListProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.selectBusiness,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              businessesAsync.when(
                loading: () => const AppLoading(),
                error: (e, _) => Text(e.toString()),
                data: (businesses) => DropdownButtonFormField<BusinessEntity>(
                  value: selectedBusiness,
                  hint: Text(context.l10n.selectBusiness),
                  decoration: const InputDecoration(),
                  dropdownColor: AppColors.surface,
                  items: businesses
                      .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                      .toList(),
                  onChanged: (b) {
                    if (b != null) onBusinessSelected(b);
                  },
                ),
              ),
              if (selectedBusiness != null) ...[
                const SizedBox(height: 24),
                Text(
                  context.l10n.services,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                _ServiceListPicker(
                  spId: selectedBusiness!.ownerId,
                  selected: selectedService,
                  onSelected: onServiceSelected,
                ),
              ],
            ],
          ),
        ),
        if (selectedService != null)
          _FooterCta(label: context.l10n.chooseProvider, onTap: onNext),
      ],
    );
  }
}

class _ServiceListPicker extends ConsumerWidget {
  const _ServiceListPicker({
    required this.spId,
    required this.selected,
    required this.onSelected,
  });
  final String spId;
  final ServiceEntity? selected;
  final ValueChanged<ServiceEntity> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider(spId));
    return servicesAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Text(e.toString()),
      data: (services) => Column(
        children: services.map((s) {
          final isSelected = selected?.id == s.id;
          return GestureDetector(
            onTap: () => onSelected(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.12)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.design_services_rounded,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _SmallPill(
                              label: AppFormatters.formatCurrency(s.price),
                              color: AppColors.successLight,
                              textColor: AppColors.successDark,
                            ),
                            const SizedBox(width: 6),
                            _SmallPill(
                              label: AppFormatters.formatDuration(s.durationMinutes),
                              color: AppColors.surfaceVariant,
                              textColor: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 22),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 2: Select Provider ──────────────────────────────────────────────────

class _SelectProviderStep extends ConsumerWidget {
  const _SelectProviderStep({
    required this.businessId,
    required this.selectedSp,
    required this.anyProvider,
    required this.onSpSelected,
    required this.onAnySelected,
    required this.onNext,
  });

  final String businessId;
  final SpBasicInfo? selectedSp;
  final bool anyProvider;
  final ValueChanged<SpBasicInfo> onSpSelected;
  final VoidCallback onAnySelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spAsync = ref.watch(serviceProvidersListProvider(businessId));

    return Stack(
      children: [
        spAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (sps) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.selectServiceProvider,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: sps.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == sps.length) {
                      return _SpGridCard(
                        name: context.l10n.anyProvider,
                        subtitle: '',
                        imageUrl: null,
                        isSelected: anyProvider,
                        isAny: true,
                        onTap: onAnySelected,
                      );
                    }
                    final sp = sps[i];
                    return _SpGridCard(
                      name: sp.fullName,
                      subtitle: sp.specialty ?? '',
                      imageUrl: sp.profileImage,
                      isSelected: selectedSp?.spId == sp.spId,
                      isAny: false,
                      onTap: () => onSpSelected(sp),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (selectedSp != null || anyProvider)
          _FooterCta(label: context.l10n.chooseDateTime, onTap: onNext),
      ],
    );
  }
}

class _SpGridCard extends StatelessWidget {
  const _SpGridCard({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.isSelected,
    required this.isAny,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String? imageUrl;
  final bool isSelected;
  final bool isAny;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                if (isAny)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl!) : null,
                    child: imageUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0] : '?',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                          )
                        : null,
                  ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 13, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Select Date/Time ─────────────────────────────────────────────────

class _SelectDateTimeStep extends StatelessWidget {
  const _SelectDateTimeStep({
    required this.selectedDateTime,
    required this.onPick,
    required this.onNext,
  });

  final DateTime? selectedDateTime;
  final VoidCallback onPick;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                if (selectedDateTime != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppFormatters.formatDate(selectedDateTime!),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatTime(selectedDateTime!),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    context.l10n.selectDate,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: Text(
                    selectedDateTime != null
                        ? context.l10n.edit
                        : context.l10n.selectDate,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedDateTime != null)
          _FooterCta(label: context.l10n.confirmBooking, onTap: onNext),
      ],
    );
  }
}

// ─── Step 4: Confirm ──────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.service,
    required this.sp,
    required this.anyProvider,
    required this.dateTime,
    required this.booking,
    required this.onConfirm,
  });

  final ServiceEntity? service;
  final SpBasicInfo? sp;
  final bool anyProvider;
  final DateTime? dateTime;
  final bool booking;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
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
                    const SizedBox(height: 20),
                    _SummaryRow(
                      icon: Icons.design_services_rounded,
                      label: context.l10n.service,
                      value: service?.name ?? '',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.person_rounded,
                      label: context.l10n.provider,
                      value: anyProvider
                          ? context.l10n.anyProvider
                          : (sp?.fullName ?? ''),
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.calendar_today_rounded,
                      label: context.l10n.date,
                      value: dateTime != null
                          ? AppFormatters.formatDate(dateTime!)
                          : '',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.access_time_rounded,
                      label: context.l10n.time,
                      value: dateTime != null
                          ? AppFormatters.formatTime(dateTime!)
                          : '',
                    ),
                    if (service != null) ...[
                      const Divider(height: 24),
                      _SummaryRow(
                        icon: Icons.payments_rounded,
                        label: context.l10n.price,
                        value: AppFormatters.formatCurrency(service!.price),
                        valueColor: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0),
                  AppColors.background,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ElevatedButton(
              onPressed: booking ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shadowColor: AppColors.primary.withOpacity(0.4),
                elevation: 8,
              ),
              child: booking
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.l10n.confirmBooking),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
}

// ─── Shared footer CTA ────────────────────────────────────────────────────────

class _FooterCta extends StatelessWidget {
  const _FooterCta({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withOpacity(0),
                AppColors.background,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shadowColor: AppColors.primary.withOpacity(0.35),
              elevation: 8,
            ),
            child: Text(label),
          ),
        ),
      );
}

// ─── Small pill ───────────────────────────────────────────────────────────────

class _SmallPill extends StatelessWidget {
  const _SmallPill({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
        ),
      );
}
