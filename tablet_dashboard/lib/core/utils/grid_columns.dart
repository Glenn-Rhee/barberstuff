class GridColumns {
  const GridColumns._();

  // Jumlah kolom yang muat di [width], kartu minimal [minItemWidth]
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
