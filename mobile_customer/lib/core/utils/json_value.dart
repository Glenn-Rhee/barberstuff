/// Pembaca nilai JSON yang longgar. Backend kadang mengirim angka sebagai
/// string atau field yang hilang, jadi nilai yang tidak cocok jadi default.
String jsonText(Object? value) => value is String ? value : '';

double jsonDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

int jsonInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}

Map<String, dynamic>? jsonMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

/// Item-item berbentuk objek dari sebuah list JSON; selain itu list kosong.
List<T> jsonList<T>(Object? value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) return List<T>.empty();
  return value
      .whereType<Map<String, dynamic>>()
      .map(parse)
      .toList(growable: false);
}
