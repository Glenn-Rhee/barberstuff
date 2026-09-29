import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/domain/repositories/promo_repository.dart';

class GetPromoContent implements SyncUseCase<PromoContent, NoParams> {
  const GetPromoContent(this._repository);

  final PromoRepository _repository;

  @override
  PromoContent call(NoParams params) => _repository.getPromoContent();
}
