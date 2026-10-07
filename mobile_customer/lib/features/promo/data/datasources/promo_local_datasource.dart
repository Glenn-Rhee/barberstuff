import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Isi promo sementara. Tabel `promo` sudah ada di database tapi belum punya
/// route, jadi isinya ditulis di sini (teksnya di ARB supaya ikut bahasa
/// aplikasi) sampai endpointnya tersedia.
///
/// TODO(api): ini satu-satunya data yang masih ditulis tangan di aplikasi.
/// Begitu route promo jadi di backend, ganti [content] dengan datasource
/// remote di PromoRepositoryImpl, lalu hapus berkas ini beserta key ARB
/// `promoBenefit*`, `promoBanner*`, dan `promoReward*`.

class PromoLocalDataSource {
  const PromoLocalDataSource._();

  static PromoContent content(AppLocalizations l10n) => PromoContent(
    grades: grades,
    benefits: _benefits(l10n),
    banners: _banners(l10n),
    rewards: _rewards(l10n),
  );

  // Nama tier sama di semua bahasa
  static const List<GradeStep> grades = <GradeStep>[
    GradeStep(
      tier: MemberTier.silver,
      label: 'Silver',
      xp: 0,
      imageAsset: AppAssets.silverPromo,
    ),
    GradeStep(
      tier: MemberTier.gold,
      label: 'Gold',
      xp: 500,
      imageAsset: AppAssets.goldPromo,
    ),
    GradeStep(
      tier: MemberTier.platinum,
      label: 'Platinum',
      xp: 1500,
      imageAsset: AppAssets.goldPromo,
    ),
  ];

  static List<GradeBenefit> _benefits(AppLocalizations l10n) => <GradeBenefit>[
    GradeBenefit(
      iconAsset: AppAssets.giftDashboard,
      title: l10n.promoBenefitPointsTitle,
      description: l10n.promoBenefitPointsDesc,
    ),
    GradeBenefit(
      iconAsset: AppAssets.tagDashboard,
      title: l10n.promoBenefitMerchantTitle,
      description: l10n.promoBenefitMerchantDesc,
    ),
    GradeBenefit(
      iconAsset: AppAssets.ticketPromo,
      title: l10n.promoBenefitVoucherTitle,
      description: l10n.promoBenefitVoucherDesc,
    ),
  ];

  static List<PromoBanner> _banners(AppLocalizations l10n) => <PromoBanner>[
    PromoBanner(
      id: 'cashback-20',
      title: l10n.promoBannerCashbackTitle,
      subtitle: l10n.promoBannerCashbackSubtitle,
      footnote: l10n.promoBannerCashbackFootnote,
      iconAsset: AppAssets.ticketPromo,
    ),
    PromoBanner(
      id: 'paket-hemat',
      title: l10n.promoBannerBundleTitle,
      subtitle: l10n.promoBannerBundleSubtitle,
      footnote: l10n.promoBannerBundleFootnote,
      iconAsset: AppAssets.giftDashboard,
      highlighted: false,
    ),
    PromoBanner(
      id: 'cashback-20-b',
      title: l10n.promoBannerCashbackTitle,
      subtitle: l10n.promoBannerCashbackSubtitle,
      footnote: l10n.promoBannerCashbackFootnote,
      iconAsset: AppAssets.ticketPromo,
    ),
  ];

  static List<RewardVoucher> _rewards(AppLocalizations l10n) => <RewardVoucher>[
    RewardVoucher(
      id: 'diskon-50',
      title: l10n.promoRewardHalfOffTitle,
      description: l10n.promoRewardHalfOffDesc,
      points: 1000,
      imageAsset: AppAssets.dummyPromo,
    ),
    RewardVoucher(
      id: 'antrean-prioritas',
      title: l10n.promoRewardPriorityTitle,
      description: l10n.promoRewardPriorityDesc,
      points: 1200,
      imageAsset: AppAssets.dummyPromo,
    ),
    RewardVoucher(
      id: 'gratis-keramas',
      title: l10n.promoRewardWashTitle,
      description: l10n.promoRewardWashDesc,
      points: 600,
      imageAsset: AppAssets.dummyPromo,
    ),
  ];
}
