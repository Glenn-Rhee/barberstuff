class ApiResponse {
  const ApiResponse({
    required this.data,
    this.message,
    this.meta,
    this.status,
    this.statusCode,
  });

  final String? message;
  final Map<dynamic, dynamic>? meta;
  final Object? data;
  final String? status;
  final int? statusCode;

  List<Map<String, dynamic>> get list => [
    for (final item in (data as List? ?? const []))
      if (item is Map) item.cast<String, dynamic>(),
  ];

  Map<String, dynamic> get map =>
      (data as Map? ?? const {}).cast<String, dynamic>();

  int get totalData => (meta?['total_data'] as num?)?.toInt() ?? list.length;
  int get totalPages => (meta?['total_pages'] as num?)?.toInt() ?? 1;
}
