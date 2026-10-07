import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

abstract interface class PromoRepository {
  /// Sinkron selama isinya masih ditulis di aplikasi, teksnya ikut bahasa
  /// [l10n]. Ubah jadi Future (tanpa [l10n]) begitu promo diambil dari
  /// backend.
  PromoContent getPromoContent(AppLocalizations l10n);
}
