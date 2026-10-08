import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/features/admin/shared/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/shared/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/shared/domain/entities/branch_draft.dart';
import 'package:tablet_dashboard/features/admin/shared/presentation/provider/local_list_controller.dart';

// Semua cabang di halaman Mengelola Cabang (GET /store)
class BranchListController extends LocalListController<Branch> {
  BranchListController(this._api) : super(pageSize: 6);

  final BranchApi _api;

  @override
  Future<List<Branch>> fetch() => _api.branches();

  @override
  bool accepts(Branch branch, String keyword) =>
      keyword.isEmpty ||
      branch.name.toLowerCase().contains(keyword) ||
      (branch.address?.toLowerCase().contains(keyword) ?? false);

  @override
  int compare(Branch a, Branch b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  // Foto diunggah dulu, baru cabang dibuat pakai object key-nya
  Future<String?> create(BranchDraft draft, PickedPhoto photo) =>
      mutate(() async {
        final key = await _api.uploadImage(photo.bytes, photo.fileName);
        await _api.createBranch(draft, bannerKey: key);
      });
}
