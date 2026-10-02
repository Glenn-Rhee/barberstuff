class Paged<T> {
  const Paged({
    required this.items,
    required this.totalPages,
    required this.totalData,
  });

  final List<T> items;
  final int totalData;
  final int totalPages;
}
