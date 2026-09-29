import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail.dart';

class StoreRepository {
  StoreRepository(this._remote);

  final StoreRemoteDataSource _remote;

  Future<StoreDetail> getStoreDetail(String id) async {
    try {
      return await _remote.getStoreDetail(id);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<CapsterItem>> getCapsters(String idStore) async {
    try {
      return await _remote.getCapsters(idStore);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
