import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/repositories/store_repository_impl.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_capsters.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_services.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Rakitan fitur cabang: datasource → repository → use case.
/// Butuh [DioClient] dan [AppCache] sudah terpasang di atasnya.
List<SingleChildWidget> storeProviders() => <SingleChildWidget>[
  Provider<StoreRemoteDataSource>(
    create: (ctx) => StoreRemoteDataSource(ctx.read<DioClient>().dio),
  ),
  Provider<StoreRepository>(
    create: (ctx) => StoreRepositoryImpl(
      ctx.read<StoreRemoteDataSource>(),
      ctx.read<AppCache>(),
    ),
  ),
  ...storeUseCases(),
];

/// Use case saja, supaya tes bisa memasang [StoreRepository] palsu.
List<SingleChildWidget> storeUseCases() => <SingleChildWidget>[
  Provider<GetStores>(create: (ctx) => GetStores(ctx.read<StoreRepository>())),
  Provider<GetStoreDetail>(
    create: (ctx) => GetStoreDetail(ctx.read<StoreRepository>()),
  ),
  Provider<GetStoreCapsters>(
    create: (ctx) => GetStoreCapsters(ctx.read<StoreRepository>()),
  ),
  Provider<GetStoreServices>(
    create: (ctx) => GetStoreServices(ctx.read<StoreRepository>()),
  ),
];
