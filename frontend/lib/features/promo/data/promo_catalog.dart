import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/promo/domain/promo_content.dart';

/// Isi promo sementara. Tabel `promo` sudah ada di database tapi belum punya
/// route, jadi teksnya ditulis di sini sampai endpointnya tersedia.
class PromoCatalog {
  const PromoCatalog._();

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

  static const List<GradeBenefit> benefits = <GradeBenefit>[
    GradeBenefit(
      iconAsset: AppAssets.giftDashboard,
      title: 'A-Poin Reguler',
      description:
          'Dapatkan cashback poin reguler hingga 5% untuk setiap transaksi '
          'merchant mitra.',
    ),
    GradeBenefit(
      iconAsset: AppAssets.tagDashboard,
      title: 'Promo Merchant',
      description:
          'Diskon eksklusif s.d 30% di berbagai restoran, kafe, dan outlet '
          'favorit terpilih.',
    ),
    GradeBenefit(
      iconAsset: AppAssets.ticketPromo,
      title: 'Voucher Spesial Hari Raya',
      description:
          'Hadiah langsung berupa voucher belanja senilai Rp100.000 saat '
          'momen spesial.',
    ),
  ];

  static const List<PromoBanner> banners = <PromoBanner>[
    PromoBanner(
      id: 'cashback-20',
      title: 'Cashback 20%',
      subtitle: 'Untuk semua layanan',
      footnote: 'Min. transaksi Rp150.000',
      iconAsset: AppAssets.ticketPromo,
    ),
    PromoBanner(
      id: 'paket-hemat',
      title: 'Paket Hemat',
      subtitle: 'Haircut 5x',
      footnote: 'Hemat hingga 15%',
      iconAsset: AppAssets.giftDashboard,
      highlighted: false,
    ),
    PromoBanner(
      id: 'cashback-20-b',
      title: 'Cashback 20%',
      subtitle: 'Untuk semua layanan',
      footnote: 'Min. transaksi Rp150.000',
      iconAsset: AppAssets.ticketPromo,
    ),
  ];

  static const List<RewardVoucher> rewards = <RewardVoucher>[
    RewardVoucher(
      id: 'diskon-50',
      title: 'Diskon 50% Potong Rambut',
      description:
          'Dapatkan akses eksklusif untuk potongan harga layanan potong '
          'rambut dan perawatan jenggot pilihan. Nikmati hasil cukur terbaik '
          'langsung dari barber profesional kami dengan standar pelayanan '
          'premium.',
      points: 1000,
      imageAsset: AppAssets.dummyPromo,
    ),
    RewardVoucher(
      id: 'antrean-prioritas',
      title: 'Akses Antrean Prioritas Cukur',
      description:
          'Lewati antrean dan langsung dilayani di cabang pilihanmu. Berlaku '
          'untuk satu kali kunjungan pada jam operasional normal.',
      points: 1200,
      imageAsset: AppAssets.dummyPromo,
    ),
    RewardVoucher(
      id: 'gratis-keramas',
      title: 'Gratis Keramas & Hair Tonic',
      description:
          'Tambahan keramas dan hair tonic tanpa biaya untuk setiap layanan '
          'potong rambut. Berlaku di seluruh cabang Barberstuff.',
      points: 600,
      imageAsset: AppAssets.dummyPromo,
    ),
  ];
}
