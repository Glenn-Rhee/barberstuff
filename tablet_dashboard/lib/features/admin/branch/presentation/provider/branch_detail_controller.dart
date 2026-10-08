import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';

// Profil cabang untuk Detail & Edit, awalnya dari daftar lalu GET /store/{id}
class BranchDetailController extends ChangeNotifier {
  BranchDetailController(this._api, this.branch);

  final BranchApi _api;

  Branch branch;
  bool loading = false;
  String? error;
  bool _disposed = false;

  String get id => branch.id;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      branch = await _api.branch(id);
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Ubah data lalu muat ulang. Balikin pesan error, null = berhasil
  Future<String?> update({
    String? name,
    String? phone,
    String? description,
    String? address,
    String? openHour,
    String? closeHour,
    double? latitude,
    double? longitude,
    BranchType? type,
    bool? open,
  }) => _run(
    () => _api.updateBranch(
      id,
      name: name,
      phone: phone,
      description: description,
      address: address,
      openHour: openHour,
      closeHour: closeHour,
      latitude: latitude,
      longitude: longitude,
      type: type,
      open: open,
    ),
  );

  Future<String?> changeBanner(PickedPhoto photo) => _run(() async {
    final key = await _api.uploadImage(photo.bytes, photo.fileName);
    await _api.updateBranch(id, bannerKey: key);
  });

  Future<String?> delete() async {
    try {
      await _api.deleteBranch(id);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      return e.message;
    }
    await load();
    return null;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
