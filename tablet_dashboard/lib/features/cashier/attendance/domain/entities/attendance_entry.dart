enum AttendanceStatus {
  present('Hadir'),
  absent('Tidak Hadir');

  const AttendanceStatus(this.label);

  final String label;
}

// Absensi satu capster hari ini: status dan jam dicatat
class AttendanceEntry {
  const AttendanceEntry({required this.status, required this.at});

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) =>
      AttendanceEntry(
        status: json['status'] == AttendanceStatus.absent.name
            ? AttendanceStatus.absent
            : AttendanceStatus.present,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );

  final AttendanceStatus status;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'at': at.toIso8601String(),
  };
}

// Jumlah hadir / tidak hadir / belum absen
class AttendanceSummary {
  const AttendanceSummary({
    required this.present,
    required this.absent,
    required this.pending,
  });

  final int present;
  final int absent;
  final int pending;
}
