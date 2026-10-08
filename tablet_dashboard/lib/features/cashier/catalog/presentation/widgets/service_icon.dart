import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

// Ikon dari nama layanan, default gunting (service) / bintang (paket)
class ServiceIcon {
  const ServiceIcon._();

  static const _byKeyword = [
    (
      ['jenggot', 'kumis', 'beard', 'shave', 'cukur bersih'],
      AppAsset.beardIcon,
    ),
    (['keramas', 'cuci', 'wash', 'shampoo'], AppAsset.hairWashIcon),
    (['styling', 'pomade', 'blow'], AppAsset.hairStylingIcon),
    (['creambath', 'cream', 'masker', 'spa'], AppAsset.creambathIcon),
    (
      ['cat', 'warna', 'color', 'colour', 'bleach', 'highlight'],
      AppAsset.hairColorIcon,
    ),
  ];

  static String of(ServiceItem item) {
    final name = item.name.toLowerCase();
    if (item.type == ServiceType.package) {
      return name.contains('premium') || name.contains('vip')
          ? AppAsset.premiumIcon
          : AppAsset.packageIcon;
    }
    for (final (keywords, icon) in _byKeyword) {
      if (keywords.any(name.contains)) return icon;
    }
    return AppAsset.scissorsIcon;
  }
}
