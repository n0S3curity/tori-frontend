import '../../l10n/app_localizations.dart';
import '../extensions/string_extensions.dart';

class AppValidators {
  AppValidators._();

  static String? Function(String?) required(AppLocalizations l10n) =>
      (value) => (value == null || value.trim().isEmpty) ? l10n.validationRequired : null;

  static String? Function(String?) email(AppLocalizations l10n) =>
      (value) {
        if (value == null || value.isEmpty) return l10n.validationRequired;
        if (!value.isValidEmail) return l10n.validationEmail;
        return null;
      };

  static String? Function(String?) phone(AppLocalizations l10n) =>
      (value) {
        if (value == null || value.isEmpty) return l10n.validationRequired;
        if (!value.isValidPhone) return l10n.validationPhone;
        return null;
      };

  static String? Function(String?) minLength(AppLocalizations l10n, int min) =>
      (value) {
        if (value == null || value.isEmpty) return l10n.validationRequired;
        if (value.length < min) return l10n.validationMinLength(min);
        return null;
      };

  static String? Function(String?) combine(List<String? Function(String?)> validators) =>
      (value) {
        for (final v in validators) {
          final result = v(value);
          if (result != null) return result;
        }
        return null;
      };
}
