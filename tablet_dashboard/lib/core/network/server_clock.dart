import 'dart:io';

import 'package:flutter/foundation.dart';

// Jam server dari header Date, karena jam tablet bisa salah
class ServerClock extends ChangeNotifier {
  // Selisih di atas ini dianggap jam tablet salah dan perlu ditegur
  static const tolerance = Duration(minutes: 2);

  // Header Date cuma per detik, selisih sekecil ini diabaikan
  static const _jitter = Duration(seconds: 2);

  Duration _offset = Duration.zero;

  // Jam server dikurangi jam tablet
  Duration get offset => _offset;

  bool get drifted => _offset.abs() > tolerance;

  // Waktu sekarang menurut server
  DateTime now() => DateTime.now().add(_offset);

  // Dipanggil ApiClient tiap ada respons, [httpDate] = isi header Date
  void sync(String? httpDate) {
    if (httpDate == null) return;
    final DateTime server;
    try {
      server = HttpDate.parse(httpDate);
    } on HttpException {
      return;
    }
    final offset = server.difference(DateTime.now());
    if ((offset - _offset).abs() < _jitter) return;
    _offset = offset;
    notifyListeners();
  }
}
