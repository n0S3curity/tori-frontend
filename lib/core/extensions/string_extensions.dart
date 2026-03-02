extension StringExtensions on String {
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);

  bool get isValidPhone =>
      RegExp(r'^\+?[1-9]\d{7,14}$').hasMatch(replaceAll(RegExp(r'\s|-'), ''));

  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
