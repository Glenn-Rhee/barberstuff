/// Format tanggal yang dipakai berulang di form dan request API.
library;

String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// Tampilan tanggal di form, misalnya 31/12/2000.
String formatDayMonthYear(DateTime date) =>
    '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

/// Tanggal (tanpa jam) yang dikirim ke server, misalnya 2000-12-31T00:00:00Z.
String formatApiDate(DateTime date) =>
    '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}T00:00:00Z';
