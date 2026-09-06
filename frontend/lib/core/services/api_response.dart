class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.isSuccess,
  });

  final T? data;
  final String message;
  final int statusCode;
  final bool isSuccess;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? parser,
  ) {
    final dynamic raw = json.containsKey('data') ? json['data'] : json['data:'];
    T? parsed;

    if (parser != null && raw is Map<String, dynamic>) {
      parsed = parser(raw);
    }

    return ApiResponse<T>(
      data: parsed,
      message: (json['message'] as String?) ?? '',
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      isSuccess: json['status'] == 'success',
    );
  }
}
