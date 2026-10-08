class Paged<T> {
  const Paged({
    required this.items,
    required this.totalPages,
    required this.totalData,
  });

  // meta backend salah hitung, jadi halaman penuh = anggap masih ada lagi
  factory Paged.fromPage(
    List<T> items, {
    required int page,
    required int limit,
  }) => Paged(
    items: items,
    totalPages: items.length < limit ? page : page + 1,
    totalData: (page - 1) * limit + items.length,
  );

  final List<T> items;
  final int totalData;
  final int totalPages;
}
