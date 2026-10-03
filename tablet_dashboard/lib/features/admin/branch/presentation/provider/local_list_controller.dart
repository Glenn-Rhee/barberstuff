import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';

// Daftar yang dimuat semua sekali, lalu cari, urut, dan halaman diproses
// di tablet. meta.total_pages backend salah hitung, jadi jumlah halaman
// dihitung dari data yang sudah dimuat
abstract class LocalListController<T> extends ChangeNotifier {
  LocalListController({required this.pageSize});

  final int pageSize;

  List<T> all = const [];
  String query = '';
  int page = 1;
  bool loading = false;
  String? error;
  bool _disposed = false;

  Future<List<T>> fetch();

  // [keyword] sudah huruf kecil, kosong = tanpa kata kunci
  bool accepts(T item, String keyword);

  int compare(T a, T b);

  // Hasil cari + filter, sudah urut, semua halaman
  List<T> get filtered {
    final keyword = query.trim().toLowerCase();
    return [
      for (final item in all)
        if (accepts(item, keyword)) item,
    ]..sort(compare);
  }

  int get totalPages {
    final count = filtered.length;
    return count == 0 ? 1 : (count / pageSize).ceil();
  }

  // Isi halaman yang sedang dibuka
  List<T> get visible =>
      filtered.skip((page - 1) * pageSize).take(pageSize).toList();

  // [silent] = muat ulang di belakang layar, data lama tetap tampil
  Future<void> refresh({bool silent = false}) async {
    if (silent && loading) return;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      all = await fetch();
      page = page.clamp(1, totalPages);
      error = null;
    } on ApiException catch (e) {
      if (!silent) {
        error = e.message;
        all = const [];
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Kirim perubahan ke backend lalu muat ulang.
  // Balikin pesan error, atau null kalau berhasil
  Future<String?> mutate(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      return e.message;
    }
    await refresh(silent: true);
    return null;
  }

  // Ganti kata kunci / filter / urutan, lalu balik ke halaman 1
  void change(VoidCallback update) {
    update();
    page = 1;
    notifyListeners();
  }

  void setQuery(String value) => change(() => query = value);

  void setPage(int value) {
    page = value.clamp(1, totalPages);
    notifyListeners();
  }

  @override
  void notifyListeners() {
    // Halaman sudah ditutup saat request selesai
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
