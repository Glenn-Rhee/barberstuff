import 'package:mobile_barberstuff/features/promo/data/datasources/promo_local_datasource.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/domain/repositories/promo_repository.dart';

class PromoRepositoryImpl implements PromoRepository {
  const PromoRepositoryImpl();

  @override
  PromoContent getPromoContent() => const PromoContent(
    grades: PromoLocalDataSource.grades,
    benefits: PromoLocalDataSource.benefits,
    banners: PromoLocalDataSource.banners,
    rewards: PromoLocalDataSource.rewards,
  );
}
