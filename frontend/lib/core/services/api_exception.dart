enum ApiErrorType { timeout, connection, server, unknown }

class ApiException implements Exception {
  const ApiException(this.type, {this.statusCode, this.rawMessage});

  final ApiErrorType type;
  final int? statusCode;
  final String? rawMessage;

  @override
  String toString() => 'ApiException(${type.name}, $statusCode, $rawMessage)';
}
