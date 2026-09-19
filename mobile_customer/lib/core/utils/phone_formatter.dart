class PhoneFormatter {
  const PhoneFormatter._();

  static const String _countryCode = '62';

  static String display(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return raw.trim();

    final String national = _toNational(digits);
    if (national.length < 4) return '+$_countryCode $national';

    final String head = national.substring(0, 3);
    final String rest = national.substring(3);
    final int split = rest.length <= 6 ? 3 : 4;

    final List<String> groups = <String>[
      head,
      rest.substring(0, split),
      if (rest.length > split) rest.substring(split),
    ];

    return '+$_countryCode ${groups.join('-')}';
  }

  static String _toNational(String digits) {
    if (digits.startsWith('0')) return digits.substring(1);
    if (digits.startsWith(_countryCode)) {
      return digits.substring(_countryCode.length);
    }
    return digits;
  }
}
