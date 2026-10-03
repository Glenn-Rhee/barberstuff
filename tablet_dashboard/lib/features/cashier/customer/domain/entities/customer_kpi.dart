// Angka ringkasan dari GET /customer (kpi)
class CustomerKpi {
  const CustomerKpi({this.total = 0, this.newThisMonth = 0});

  factory CustomerKpi.fromJson(Map<String, dynamic> json) => CustomerKpi(
    total: (json['total_customers'] as num?)?.toInt() ?? 0,
    newThisMonth: (json['total_new_customers'] as num?)?.toInt() ?? 0,
  );

  // Semua pelanggan terdaftar
  final int total;

  // Pelanggan baru bulan ini
  final int newThisMonth;
}
