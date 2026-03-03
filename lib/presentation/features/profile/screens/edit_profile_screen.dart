import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final success = await ref.read(authProvider.notifier).updateProfile({
      'firstName': _firstNameCtrl.text.trim(),
      'lastName':  _lastNameCtrl.text.trim(),
    });

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      context.showSnackBar(context.l10n.success);
      Navigator.of(context).pop();
    } else {
      context.showSnackBar(context.l10n.error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar (read-only display)
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: context.textTheme.headlineMedium
                            ?.copyWith(color: AppColors.primary),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),

            // First name
            TextFormField(
              controller: _firstNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.firstName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 16),

            // Last name
            TextFormField(
              controller: _lastNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.lastName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 12),

            // Read-only email note
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined, color: AppColors.textHint),
              title: Text(user.email, style: context.textTheme.bodyMedium),
              subtitle: Text(
                context.l10n.email,
                style: context.textTheme.bodySmall,
              ),
            ),

            // Read-only phone note
            if (user.phone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined, color: AppColors.textHint),
                title: Text(user.phone!, style: context.textTheme.bodyMedium),
                subtitle: Text(
                  context.l10n.phone,
                  style: context.textTheme.bodySmall,
                ),
              ),

            const SizedBox(height: 32),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
