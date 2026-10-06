import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch_draft.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/local_list_controller.dart';

enum BranchSort {
  name('Nama A-Z'),
  newest('Terbaru'),
  rating('Rating Tertinggi');

  const BranchSort(this.label);

  final String label;
}

// Semua cabang di halaman Mengelola Cabang (GET /store)
class BranchListController extends LocalListController<Branch> {
  BranchListController(this._api) : super(pageSize: 6);

  final BranchApi _api;

  BranchSort sort = BranchSort.name;

  @override
  Future<List<Branch>> fetch() => _api.branches();

  @override
  bool accepts(Branch branch, String keyword) =>
      keyword.isEmpty ||
      branch.name.toLowerCase().contains(keyword) ||
      (branch.address?.toLowerCase().contains(keyword) ?? false);

  @override
  int compare(Branch a, Branch b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    final bySort = switch (sort) {
      BranchSort.name => 0,
      BranchSort.newest => (b.createdAt ?? DateTime(0)).compareTo(
        a.createdAt ?? DateTime(0),
      ),
      BranchSort.rating => b.rating.compareTo(a.rating),
    };
    return bySort != 0 ? bySort : byName;
  }

  void setSort(BranchSort value) => change(() => sort = value);

  // Foto diunggah dulu, baru cabang dibuat pakai object key-nya
  Future<String?> create(BranchDraft draft, PickedPhoto photo) =>
      mutate(() async {
        final key = await _api.uploadImage(photo.bytes, photo.fileName);
        await _api.createBranch(draft, bannerKey: key);
      });
}
