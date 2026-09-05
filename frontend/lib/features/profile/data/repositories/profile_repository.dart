import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';

class ProfileRepository {
  ProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  Future<CustomerProfile> getCustomerProfile() async {
    try {
      return await _remote.getCustomerProfile();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
