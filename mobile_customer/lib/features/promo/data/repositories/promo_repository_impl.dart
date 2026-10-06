import 'package:mobile_barberstuff/features/promo/data/datasources/promo_local_datasource.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/domain/repositories/promo_repository.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class PromoRepositoryImpl implements PromoRepository {
  const PromoRepositoryImpl();

  @override
  PromoContent getPromoContent(AppLocalizations l10n) =>
      PromoLocalDataSource.content(l10n);
}
