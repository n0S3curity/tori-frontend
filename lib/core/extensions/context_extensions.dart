import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(this).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String body,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) =>
      showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText ?? l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error)
                  : null,
              child: Text(confirmText ?? l10n.confirm),
            ),
          ],
        ),
      );
}
