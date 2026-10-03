import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';

abstract interface class PromoRepository {
  /// Sinkron selama isinya masih ditulis di aplikasi. Ubah jadi Future
  /// begitu promo diambil dari backend.
  PromoContent getPromoContent();
}
