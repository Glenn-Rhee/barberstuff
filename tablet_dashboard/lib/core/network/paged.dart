class Paged<T> {
  const Paged({
    required this.items,
    required this.totalPages,
    required this.totalData,
  });

<<<<<<< HEAD
  // meta.total_data / total_pages dari backend tidak bisa dipakai: Count di
  // repository jalan sebelum filter, jadi yang dihitung seluruh tabel.
  // Jumlah halaman ditebak dari isi halaman ini: penuh = mungkin masih ada lagi
=======
  // meta backend salah hitung, jadi halaman penuh = anggap masih ada lagi
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
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
