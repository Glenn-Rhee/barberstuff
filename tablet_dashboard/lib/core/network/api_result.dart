class ApiResult {
  const ApiResult({required this.data, this.meta, this.message});

  final String? message;
  final Map<dynamic, dynamic>? meta;
  final Object? data;

  List<Map<String, dynamic>> get list => [
    for (final item in (data as List? ?? const []))
      if (item is Map) item.cast<String, dynamic>(),
  ];

  Map<String, dynamic> get map =>
      (data as Map? ?? const {}).cast<String, dynamic>();

  int get totalData => (meta?['total_data'] as num?)?.toInt() ?? list.length;
  int get totalPages => (meta?['total_pages'] as num?)?.toInt() ?? 1;
}
