class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  // Belum ada izin atau belum login
  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  // Request tidak valid (400)
  bool get isValid => statusCode == 400;

  @override
  // Mengembalikan cetakan message
  String toString() => message;
}
