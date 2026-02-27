class InputSanitizer {
  static double? parseDouble(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }
}
