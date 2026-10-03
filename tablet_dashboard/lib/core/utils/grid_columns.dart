class GridColumns {
  const GridColumns._();

  // Jumlah kolom yang muat di [width] tanpa kartu lebih sempit dari
  // [minItemWidth]. Layar tablet tiap cabang bisa beda, jadi kolom
  // dihitung dari lebar asli, bukan angka tetap
  static int of(
    double width, {
    required double minItemWidth,
    required double spacing,
    int max = 6,
  }) {
    final columns = ((width + spacing) / (minItemWidth + spacing)).floor();
    return columns.clamp(1, max);
  }
}
