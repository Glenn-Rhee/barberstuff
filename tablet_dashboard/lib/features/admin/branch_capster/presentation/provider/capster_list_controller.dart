import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/features/admin/branch_list/data/branch_api.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/shared/provider/local_list_controller.dart';

enum CapsterSort {
  ratingHigh('Rating Tertinggi'),
  ratingLow('Rating Terendah'),
  name('Nama A-Z');

  const CapsterSort(this.label);

  final String label;
}

// Tab Capster di detail cabang
class CapsterListController extends LocalListController<Capster> {
  CapsterListController(this._api, this.storeId) : super(pageSize: 5);

  final BranchApi _api;
  final String storeId;

  CapsterSort sort = CapsterSort.ratingHigh;

  @override
  Future<List<Capster>> fetch() => _api.capsters(storeId);

  @override
  bool accepts(Capster capster, String keyword) =>
      keyword.isEmpty || capster.name.toLowerCase().contains(keyword);

  @override
  int compare(Capster a, Capster b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    final bySort = switch (sort) {
      CapsterSort.ratingHigh => b.rating.compareTo(a.rating),
      CapsterSort.ratingLow => a.rating.compareTo(b.rating),
      CapsterSort.name => 0,
    };
    return bySort != 0 ? bySort : byName;
  }

  void setSort(CapsterSort value) => change(() => sort = value);

  // Capster baru selalu aktif (aturan backend)
  Future<String?> create({required String name, PickedPhoto? photo}) =>
      mutate(() async {
        await _api.createCapster(
          storeId: storeId,
          name: name,
          imageKey: await _upload(photo),
        );
      });

  // Field null = tidak diubah
  Future<String?> update(
    Capster capster, {
    String? name,
    bool? active,
    PickedPhoto? photo,
  }) => mutate(() async {
    await _api.updateCapster(
      capster.id,
      name: name,
      active: active,
      imageKey: await _upload(photo),
    );
  });

  // Pindah ke cabang lain, lalu hilang dari daftar cabang ini
  Future<String?> move(Capster capster, String storeId) =>
      mutate(() => _api.updateCapster(capster.id, storeId: storeId));

  Future<String?> delete(Capster capster) =>
      mutate(() => _api.deleteCapster(capster.id));

  Future<String?> _upload(PickedPhoto? photo) async => photo == null
      ? null
      : await _api.uploadImage(photo.bytes, photo.fileName);
}
