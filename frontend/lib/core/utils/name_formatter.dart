class NameFormatter {
  const NameFormatter._();

  static String firstName(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final int space = trimmed.indexOf(RegExp(r'\s'));
    return space == -1 ? trimmed : trimmed.substring(0, space);
  }
}
