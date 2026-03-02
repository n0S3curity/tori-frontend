import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String formatDate(DateTime date, {String locale = 'he'}) =>
      DateFormat('dd/MM/yyyy', locale).format(date.toLocal());

  static String formatTime(DateTime date, {String locale = 'he'}) =>
      DateFormat('HH:mm', locale).format(date.toLocal());

  static String formatDateTime(DateTime date, {String locale = 'he'}) =>
      DateFormat('dd/MM/yyyy HH:mm', locale).format(date.toLocal());

  static String formatCurrency(double amount, {String symbol = '₪'}) =>
      '$symbol${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String formatPercent(double value) => '${value.toStringAsFixed(1)}%';
}
