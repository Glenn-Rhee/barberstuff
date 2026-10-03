import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mobile_barberstuff/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile_barberstuff/features/profile/domain/usecases/get_customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/usecases/update_customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Rakitan fitur profil. Butuh [DioClient], [AppCache], dan
/// [DebugOverrides] sudah terpasang di atasnya.
List<SingleChildWidget> profileProviders() => <SingleChildWidget>[
  Provider<ProfileRemoteDataSource>(
    create: (ctx) => ProfileRemoteDataSource(ctx.read<DioClient>().dio),
  ),
  Provider<ProfileRepository>(
    create: (ctx) => ProfileRepositoryImpl(
      ctx.read<ProfileRemoteDataSource>(),
      ctx.read<AppCache>(),
    ),
  ),
  ...profileUseCases(),
  // Lazy: baru memuat profil saat layar pertama membacanya, bukan saat
  // aplikasi dibuka, supaya tidak menembak API sebelum login.
  ChangeNotifierProvider<ProfileProvider>(
    create: (ctx) => ProfileProvider(
      ctx.read<GetCustomerProfile>(),
      ctx.read<DebugOverrides>(),
    ),
  ),
];

/// Use case saja, supaya tes bisa memasang [ProfileRepository] palsu.
List<SingleChildWidget> profileUseCases() => <SingleChildWidget>[
  Provider<GetCustomerProfile>(
    create: (ctx) => GetCustomerProfile(ctx.read<ProfileRepository>()),
  ),
  Provider<UpdateCustomerProfile>(
    create: (ctx) => UpdateCustomerProfile(ctx.read<ProfileRepository>()),
  ),
];
