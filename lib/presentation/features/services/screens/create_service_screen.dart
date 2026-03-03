import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/service_entity.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../../data/repositories/services_repository_impl.dart';
import '../providers/services_provider.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key, this.service});

  /// Non-null = edit mode; null = create mode.
  final ServiceEntity? service;

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _notesCtrl;

  final Set<String> _selectedDays = {};
  final Map<String, TimeOfDay> _startTimes = {};
  final Map<String, TimeOfDay> _endTimes = {};

  bool _saving = false;

  static const List<String> _allDays = [
    'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat',
  ];

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameCtrl     = TextEditingController(text: s?.name ?? '');
    _durationCtrl = TextEditingController(
      text: s != null ? s.durationMinutes.toString() : '',
    );
    _priceCtrl = TextEditingController(
      text: s != null
          ? (s.price % 1 == 0 ? s.price.toInt().toString() : s.price.toStringAsFixed(2))
          : '',
    );
    _notesCtrl = TextEditingController(text: s?.notes ?? '');

    if (s != null) {
      _selectedDays.addAll(s.availableDays);
      for (final tr in s.timeRanges) {
        final sp = tr.start.split(':');
        final ep = tr.end.split(':');
        _startTimes[tr.day] =
            TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1]));
        _endTimes[tr.day] =
            TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1]));
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTod(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _dayLabel(String day) {
    final l = context.l10n;
    return switch (day) {
      'sun' => l.sun,
      'mon' => l.mon,
      'tue' => l.tue,
      'wed' => l.wed,
      'thu' => l.thu,
      'fri' => l.fri,
      'sat' => l.sat,
      _     => day,
    };
  }

  Future<void> _pickTime(String day, bool isStart) async {
    final current = isStart
        ? (_startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTimes[day] ?? const TimeOfDay(hour: 18, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTimes[day] = picked;
        else _endTimes[day] = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);

    final timeRanges = _selectedDays.map((day) {
      final start = _startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0);
      final end   = _endTimes[day]   ?? const TimeOfDay(hour: 18, minute: 0);
      return {'day': day, 'start': _formatTod(start), 'end': _formatTod(end)};
    }).toList();

    final data = {
      'name':             _nameCtrl.text.trim(),
      'durationMinutes':  int.parse(_durationCtrl.text.trim()),
      'price':            double.parse(_priceCtrl.text.trim()),
      'availableDays':    _selectedDays.toList(),
      'timeRanges':       timeRanges,
      'notes':            _notesCtrl.text.trim(),
    };

    final repo = ref.read(servicesRepositoryProvider);
    final result = _isEdit
        ? await repo.updateService(user.id, widget.service!.id, data)
        : await repo.createService(user.id, data);

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => context.showSnackBar(failure.userMessage, isError: true),
      (_) {
        ref.invalidate(servicesProvider(user.id));
        context.showSnackBar(
          _isEdit ? context.l10n.success : context.l10n.createService,
        );
        Navigator.of(context).pop();
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? context.l10n.editService : context.l10n.createService),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Service name ───────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.serviceName,
                prefixIcon: const Icon(Icons.design_services_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Duration + Price ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.serviceDuration,
                      suffixText: context.l10n.minutes,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.l10n.validationRequired;
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return context.l10n.validationRequired;
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: context.l10n.servicePrice,
                      suffixText: context.l10n.currencySymbol,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.l10n.validationRequired;
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return context.l10n.validationRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Notes ─────────────────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.l10n.notes,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // ── Available days chips ───────────────────────────────────────
            Text(context.l10n.availableDays, style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _allDays.map((day) {
                final selected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(_dayLabel(day)),
                  selected: selected,
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (val) => setState(() {
                    if (val) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                      _startTimes.remove(day);
                      _endTimes.remove(day);
                    }
                  }),
                );
              }).toList(),
            ),

            // ── Per-day time ranges ────────────────────────────────────────
            if (_selectedDays.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                context.l10n.workingHoursTitle,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ..._allDays
                  .where(_selectedDays.contains)
                  .map(
                    (day) => _DayTimeRow(
                      label:       _dayLabel(day),
                      start:       _startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0),
                      end:         _endTimes[day]   ?? const TimeOfDay(hour: 18, minute: 0),
                      onPickStart: () => _pickTime(day, true),
                      onPickEnd:   () => _pickTime(day, false),
                    ),
                  ),
            ],
            const SizedBox(height: 32),

            // ── Submit ───────────────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEdit ? context.l10n.save : context.l10n.createService,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Day time row ─────────────────────────────────────────────────────────────

class _DayTimeRow extends StatelessWidget {
  const _DayTimeRow({
    required this.label,
    required this.start,
    required this.end,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String label;
  final TimeOfDay start;
  final TimeOfDay end;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time_outlined, size: 15),
                label: Text(_fmt(start)),
                onPressed: onPickStart,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('–', style: TextStyle(color: AppColors.textSecondary)),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time_outlined, size: 15),
                label: Text(_fmt(end)),
                onPressed: onPickEnd,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      );
}
