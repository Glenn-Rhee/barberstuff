import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/domain/repositories/promo_repository.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Parameternya bahasa aplikasi, karena isi promo sementara masih teks lokal.
class GetPromoContent implements SyncUseCase<PromoContent, AppLocalizations> {
  const GetPromoContent(this._repository);

  final PromoRepository _repository;

  @override
  PromoContent call(AppLocalizations l10n) => _repository.getPromoContent(l10n);
}
