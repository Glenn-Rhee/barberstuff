class ApiMeta {
  const ApiMeta({
    required this.page,
    required this.limit,
    required this.totalData,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int totalData;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      totalData: (json['total_data'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}

class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.isSuccess,
    this.meta,
  });

  final T? data;
  final String message;
  final int statusCode;
  final bool isSuccess;
  final ApiMeta? meta;

  static dynamic _rawData(Map<String, dynamic> json) {
    return json.containsKey('data') ? json['data'] : json['data:'];
  }

  static ApiMeta? _meta(Map<String, dynamic> json) {
    final dynamic raw = json['meta'];
    return raw is Map<String, dynamic> ? ApiMeta.fromJson(raw) : null;
  }

  static String _message(Map<String, dynamic> json) =>
      (json['message'] as String?) ?? '';

  static int _statusCode(Map<String, dynamic> json) =>
      (json['statusCode'] as num?)?.toInt() ?? 0;

  static bool _isSuccess(Map<String, dynamic> json) =>
      json['status'] == 'success';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? parser,
  ) {
    final dynamic raw = _rawData(json);
    T? parsed;

    if (parser != null && raw is Map<String, dynamic>) {
      parsed = parser(raw);
    }

    return ApiResponse<T>(
      data: parsed,
      message: _message(json),
      statusCode: _statusCode(json),
      isSuccess: _isSuccess(json),
      meta: _meta(json),
    );
  }

  static ApiResponse<List<E>> listFromJson<E>(
    Map<String, dynamic> json,
    E Function(Map<String, dynamic> json) parser,
  ) {
    final dynamic raw = _rawData(json);

    final List<E> parsed = raw is List
        ? raw
              .whereType<Map<String, dynamic>>()
              .map<E>(parser)
              .toList(growable: false)
        : <E>[];

    return ApiResponse<List<E>>(
      data: raw is List ? parsed : null,
      message: _message(json),
      statusCode: _statusCode(json),
      isSuccess: _isSuccess(json),
      meta: _meta(json),
    );
  }
}
