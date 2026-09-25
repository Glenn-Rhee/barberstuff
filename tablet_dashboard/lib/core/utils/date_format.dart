class DateFormatId {
  const DateFormatId._();

  static const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Senin, 27 Mei 2024
  static String longDate(DateTime value) =>
      '${_days[value.weekday - 1]}, ${value.day} ${_months[value.month - 1]} ${value.year}';

  /// 14:30
  static String time(DateTime value) => '${_two(value.hour)}:${_two(value.minute)}';

  /// 22/09/2026 14:30
  static String dateTime(DateTime value) => '${_two(value.day)}/${_two(value.month)}/${value.year} ${time(value)}';

  /// 20260922
  static String compact(DateTime value) => '${value.year}${_two(value.month)}${_two(value.day)}';

  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static String _two(int n) => n.toString().padLeft(2, '0');
}
