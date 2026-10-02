class DateFormatId {
  const DateFormatId._();

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
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

  // Senin, 27 Mei 2024
  static String longDate(DateTime value) =>
      '${_days[value.weekday - 1]}, ${value.day} ${_months[value.month - 1]} ${value.year}';

  // 14:30
  static String time(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';

  // 22/09/2026 14:30
  static String dateTime(DateTime value) =>
      '${_two(value.day)}/${_two(value.month)}/${value.year} ${time(value)}';

  // 20260922
  static String compact(DateTime value) =>
      '${value.year}${_two(value.month)}${_two(value.day)}';

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Jam dari backend, mis. "0000-01-01T09:00:00Z" -> "09:00".
  // Diambil apa adanya (jam lokal toko), jangan dikonversi zona waktu
  static String? clockOf(Object? value) {
    final match = RegExp(r'T(\d{2}):(\d{2})').firstMatch('${value ?? ''}');
    return match == null ? null : '${match[1]}:${match[2]}';
  }

  // "09:30" -> 570 (menit dari jam 00:00)
  static int minutesOf(String clock) {
    final parts = clock.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
