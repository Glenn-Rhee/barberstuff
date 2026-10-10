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

  // Senin, 27 Sep 2026
  static String mediumDate(DateTime value) =>
      '${_days[value.weekday - 1]}, ${compactDate(value)}';

  // 27 Mei 2024
  static String shortDate(DateTime value) =>
      '${value.day} ${_months[value.month - 1]} ${value.year}';

  // 27 Sep 2026
  static String compactDate(DateTime value) =>
      '${value.day} ${_months[value.month - 1].substring(0, 3)} ${value.year}';

  // September 2026
  static String monthYear(DateTime value) =>
      '${_months[value.month - 1]} ${value.year}';

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

  // "0000-01-01T09:00:00Z" -> "09:00", jam lokal toko, jangan dikonversi
  static String? clockOf(Object? value) {
    final match = RegExp(r'T(\d{2}):(\d{2})').firstMatch('${value ?? ''}');
    return match == null ? null : '${match[1]}:${match[2]}';
  }

  // "09:30" -> 570 (menit dari jam 00:00)
  static int minutesOf(String clock) {
    final parts = clock.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // "09:30" -> "2000-01-01T09:30:00.000Z", backend cuma pakai jam & menit
  static String clockToApi(String clock) {
    final minutes = minutesOf(clock);
    return DateTime.utc(
      2000,
      1,
      1,
      minutes ~/ 60,
      minutes % 60,
    ).toIso8601String();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
