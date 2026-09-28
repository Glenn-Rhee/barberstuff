// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localization.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Barberstuff';

  @override
  String get onboardingFirstTitle => 'Gaya yang pas untuk keseharianmu';

  @override
  String get onboardingFirstDescription =>
      'Temukan gaya rambut yang sesuai dengan karakter dan aktivitas harianmu.';

  @override
  String get onboardingSecondTitle => 'Booking cukur jadi lebih mudah';

  @override
  String get onboardingSecondDescription =>
      'Pilih cabang, barber, dan jam yang kamu mau tanpa perlu antre di tempat.';

  @override
  String get onboardingThirdTitle => 'Nikmati berbagai keuntungan member';

  @override
  String get onboardingThirdDescription =>
      'Kumpulkan poin di setiap kunjungan dan tukarkan dengan potongan harga.';

  @override
  String get onboardingStart => 'Ayo Mulai!';

  @override
  String get chooseLoginWelcome => 'Selamat Datang';

  @override
  String get chooseLoginGoogleText => 'Lanjutkan dengan Google';

  @override
  String get chooseLoginDividerOr => 'atau';

  @override
  String get chooseLoginWithPasswordText => 'Masuk dengan Kata Sandi';

  @override
  String get chooseLoginTextMessage => 'Belum punya akun?';

  @override
  String get chooseLoginTextLink => 'Daftar';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get registerHeadline => 'Buat Akun Anda';

  @override
  String get registerNameLabel => 'Nama Lengkap';

  @override
  String get registerPhoneLabel => 'Nomor Telepon';

  @override
  String get registerBirthDateLabel => 'Tanggal Lahir';

  @override
  String get registerGenderLabel => 'Jenis Kelamin';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Kata Sandi';

  @override
  String get registerSubmitButton => 'Lanjutkan';

  @override
  String get registerHaveAccountQuestion => 'Sudah punya akun?';

  @override
  String get registerLoginAction => 'Masuk';

  @override
  String get registerOtpSentMessage => 'OTP telah dikirim ke email Anda.';

  @override
  String get verifyPageBarText => 'Verifikasi Email';

  @override
  String get verifyHeadline => 'Periksa Email Anda';

  @override
  String verifyDescription(String email) {
    return 'Kami telah mengirimkan kode verifikasi 6 digit ke $email. Silakan masukkan kode di bawah ini.';
  }

  @override
  String get verifySubmitButton => 'Verifikasi';

  @override
  String get verifyResendQuestion => 'Tidak menerima kode?';

  @override
  String get verifyResendAction => 'Kirim ulang kode';

  @override
  String verifyResendCountdown(String time) {
    return 'Kirim ulang dalam $time';
  }

  @override
  String get verifyAttemptExhausted =>
      'Kesempatan mencoba habis. Silakan kirim ulang kode.';

  @override
  String get verifyResendSending => 'Mengirim...';

  @override
  String get verifyResendSuccess => 'Kode baru telah dikirim ke email Anda.';

  @override
  String get verifySuccessTitle => 'Selamat!';

  @override
  String get verifySuccessMessage =>
      'Email Anda telah berhasil diverifikasi. Anda sekarang dapat mengakses semua fitur aplikasi kami.';

  @override
  String get verifySuccessButton => 'Lanjutkan';

  @override
  String get loginHeadline => 'Masuk ke Akun Anda';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Kata Sandi';

  @override
  String get loginRememberMe => 'Ingat Saya';

  @override
  String get loginSubmitButton => 'Masuk';

  @override
  String get loginForgotQuestion => 'Lupa kata sandi?';

  @override
  String get loginForgotAction => 'Klik disini';

  @override
  String get loginWithGoogle => 'Masuk dengan Google';

  @override
  String get forgotPageBarText => 'Lupa Kata Sandi';

  @override
  String get forgotHeadline => 'Lupa Kata Sandi?';

  @override
  String get forgotDescription =>
      'Masukkan email akun Anda. Kami akan mengirimkan kode verifikasi untuk mengatur ulang kata sandi.';

  @override
  String get forgotSubmitButton => 'Kirim Kode';

  @override
  String get resetPageBarText => 'Kata Sandi Baru';

  @override
  String get resetHeadline => 'Buat Kata Sandi Baru';

  @override
  String get resetDescription =>
      'Kata sandi baru harus berbeda dari kata sandi yang pernah Anda pakai sebelumnya.';

  @override
  String get resetPasswordHint => 'Kata Sandi Baru';

  @override
  String get resetConfirmHint => 'Ulangi Kata Sandi Baru';

  @override
  String get resetSubmitButton => 'Simpan Kata Sandi';

  @override
  String get resetSignInFailed =>
      'Kata sandi berhasil diubah, tetapi kami gagal masuk otomatis. Silakan masuk kembali.';

  @override
  String get resetSuccessTitle => 'Selamat!';

  @override
  String get resetSuccessMessage =>
      'Kata sandi Anda berhasil diperbarui. Anda akan diarahkan ke halaman beranda.';

  @override
  String get resetSuccessButton => 'Ke Beranda';

  @override
  String get exceptionReceiveTimeout =>
      'Koneksi timeout. Periksa jaringan Anda.';

  @override
  String get exceptionConnectionError => 'Tidak dapat terhubung ke server.';

  @override
  String get exceptionDefaultType => 'Terjadi kesalahan pada server.';

  @override
  String get exceptionDefault => 'Terjadi Kesalahan yang tak terduga.';

  @override
  String validatorRequired(String label) {
    return '$label wajib diisi';
  }

  @override
  String get validatorEmailInvalid => 'Format email tidak valid';

  @override
  String validatorPasswordMin(int min) {
    return 'Kata Sandi minimal $min karakter';
  }

  @override
  String validatorPhoneMin(int min) {
    return 'Nomor Telepon minimal $min digit';
  }

  @override
  String validatorPhoneMax(int max) {
    return 'Nomor Telepon maksimal $max digit';
  }

  @override
  String get validatorPhoneDigits => 'Hanya boleh angka';

  @override
  String get validatorPasswordMismatch => 'Kata sandi tidak sama';

  @override
  String get googleSignInFailed =>
      'Gagal masuk dengan Google. Silakan coba lagi.';

  @override
  String get completeProfileTitle => 'Lengkapi Profil';

  @override
  String get completeProfileSubtitle =>
      'Sedikit lagi. Lengkapi data dirimu untuk mulai memakai Barberstuff.';

  @override
  String get completeProfileSubmit => 'Lanjutkan';

  @override
  String get completeProfileEmailLocked =>
      'Email dari Google tidak bisa diubah';

  @override
  String get avatarSheetTitle => 'Foto Profil';

  @override
  String get avatarSheetCamera => 'Ambil Foto';

  @override
  String get avatarSheetGallery => 'Pilih dari Galeri';

  @override
  String get avatarSheetRemove => 'Hapus Foto';

  @override
  String get avatarPickFailed => 'Gagal membuka galeri atau kamera. Coba lagi.';

  @override
  String get avatarPermissionDenied =>
      'Izin akses foto atau kamera ditolak. Aktifkan lewat pengaturan perangkat.';

  @override
  String homeGreeting(String name) {
    return 'Halo, $name!';
  }

  @override
  String get homeWelcomeBack => 'Selamat datang kembali';

  @override
  String homePoints(String points) {
    return '$points Poin';
  }

  @override
  String get homeMemberBadge => 'MEMBER';

  @override
  String homePointsToPremium(String points) {
    return '$points Poin lagi ke level premium';
  }

  @override
  String get homeMembershipLevel => 'Tingkat membership';

  @override
  String get homeRedeemPoints => 'Tukarkan point anda';

  @override
  String get homeBirthdayTitle => 'Spesial Hari Ulang Tahun!';

  @override
  String get homeBirthdayDescription =>
      'Diskon potongan rambut berlaku s/d 7 hari setelah ultah.';

  @override
  String get homeSeePromo => 'Lihat Promo';

  @override
  String get homeBirthdayBadge => 'Tampil terbaik setiap hari';

  @override
  String get homeBookingNow => 'Booking Sekarang';

  @override
  String get homeActionBooking => 'Booking';

  @override
  String get homeActionPackage => 'Paket';

  @override
  String get homeActionPromo => 'Promo';

  @override
  String get homeActionHistory => 'Riwayat';

  @override
  String get bookingBranchNewBadge => 'NEWBIE';

  @override
  String get homeBenefitTitle => 'Benefit Barberstuff';

  @override
  String get homeBenefitPoints => 'Poin reward setiap kali potong rambut';

  @override
  String get homeBenefitBirthday => 'Diskon khusus dan penawaran ulang tahun';

  @override
  String get homeBenefitPriority => 'Prioritas jadwal tanpa antre panjang';

  @override
  String get homeBenefitDiscountTitle => 'Diskon Lebih Banyak Cukur!';

  @override
  String get homeBenefitPointsTitle => 'Poin di Setiap Potongan';

  @override
  String get homeBenefitPriorityTitle => 'Prioritas Tanpa Antre';

  @override
  String get homeActiveBookingTitle => 'Booking Aktif';

  @override
  String get homeBookingUpcoming => 'MENDATANG';

  @override
  String homeBookingOrderId(String id) {
    return 'Order ID #$id';
  }

  @override
  String get homeBookingDetail => 'Lihat Detail';

  @override
  String homeBookingCapster(String name) {
    return 'Capster $name';
  }

  @override
  String get homeBookingEmpty => 'Belum ada booking aktif.';

  @override
  String get homeNearbyTitle => 'Cabang Terdekat';

  @override
  String get homeNearbySeeAll => 'Lihat Semua';

  @override
  String get storeListTitle => 'Semua Cabang';

  @override
  String homeNearbyDistance(String distance) {
    return '$distance km';
  }

  @override
  String get homeHistoryTitle => 'Riwayat Potongan';

  @override
  String get homeHistorySeeAll => 'Lihat Riwayat';

  @override
  String get homeHistoryEmpty => 'Belum ada riwayat potongan.';

  @override
  String get homeHistoryRebook => 'Pesan Lagi';

  @override
  String homeHistoryBy(String name) {
    return 'oleh $name';
  }

  @override
  String homeNearbyLocation(String city, String distance) {
    return '$city • $distance km';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navBooking => 'Booking';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navProfile => 'Profil';

  @override
  String get historyTitle => 'Riwayat Booking';

  @override
  String get storeDetailTitle => 'Detail Toko';

  @override
  String get storeOpen => 'BUKA';

  @override
  String get storeClosed => 'TUTUP';

  @override
  String storeReviewCount(String count) {
    return '($count reviews)';
  }

  @override
  String get storeActionCall => 'Telepon';

  @override
  String get storeActionRoute => 'Rute';

  @override
  String get storeActionShare => 'Bagikan';

  @override
  String get storeBarbers => 'Barber Kami';

  @override
  String get storeSeeAll => 'Lihat Semua';

  @override
  String get storeTabAbout => 'Tentang Kami';

  @override
  String get storeTabService => 'Layanan';

  @override
  String get storeTabPackage => 'Paket';

  @override
  String get storeTabReview => 'Ulasan';

  @override
  String get storeDescription => 'Deskripsi';

  @override
  String get storeHours => 'Jam Operasional';

  @override
  String get storeHoursEveryday => 'Setiap hari';

  @override
  String get storeAddressTitle => 'Alamat Kami';

  @override
  String get storeSeeMap => 'Lihat di Peta';

  @override
  String get storeServicesTitle => 'Services Kami';

  @override
  String get storePackagesTitle => 'Paket Kami';

  @override
  String get storeReviewsTitle => 'Ulasan Pelanggan';

  @override
  String get storeBookNow => 'Pesan Sekarang';

  @override
  String storeTypeCount(int count) {
    return '$count types';
  }

  @override
  String get storeShareCopied => 'Info toko disalin ke clipboard';

  @override
  String get storeNoBarber => 'Belum ada barber di cabang ini.';

  @override
  String get storeNoService => 'Belum ada layanan.';

  @override
  String get storeNoPackage => 'Belum ada paket.';

  @override
  String get storeNoReview => 'Belum ada ulasan.';

  @override
  String get historyTabUpcoming => 'Akan Datang';

  @override
  String get historyTabDone => 'Selesai';

  @override
  String get historyTabCanceled => 'Dibatalkan';

  @override
  String get historyBadgeProgress => 'PROGRESS';

  @override
  String get historyBadgeDone => 'DONE';

  @override
  String get historyBadgeCancel => 'CANCEL';

  @override
  String get historyNotReviewed => 'Belum diulas';

  @override
  String get historyWriteReview => 'Beri Ulasan';

  @override
  String get historySeeReview => 'Lihat Ulasan';

  @override
  String get historyYourReview => 'Ulasanmu';

  @override
  String get historyEmpty => 'Belum ada booking di daftar ini.';

  @override
  String get reviewTitle => 'Bagaimana pengalamanmu?';

  @override
  String get reviewSubtitle => 'pengalamanmu sangat berharga bagi kami';

  @override
  String get reviewCapster => 'Pelayanan Capster';

  @override
  String get reviewCashier => 'Pelayanan Kasir';

  @override
  String get reviewStore => 'Kualitas Outlet';

  @override
  String get reviewMessageLabel => 'Ceritakan Pengalamanmu Disini';

  @override
  String get reviewMessageHint => 'Tulis disini untuk riview kamu!';

  @override
  String get reviewSubmit => 'Kirim';

  @override
  String get reviewNeedStars => 'Beri bintang dulu untuk semua penilaian.';

  @override
  String get reviewThanks => 'Terima kasih atas ulasanmu!';

  @override
  String get notificationTitle => 'Notifikasi';

  @override
  String get notificationSearchHint => 'Cari notifikasi...';

  @override
  String get notificationFilterAll => 'Semua';

  @override
  String get notificationFilterUnread => 'Belum Dibaca';

  @override
  String get notificationMarkAllRead => 'Tandai semua dibaca';

  @override
  String get notificationToday => 'Hari ini';

  @override
  String get notificationYesterday => 'Kemarin';

  @override
  String get notificationEmpty => 'Belum ada notifikasi saat ini';

  @override
  String get notificationChannelName => 'Info Barberstuff';

  @override
  String get notificationChannelDescription =>
      'Info booking, poin, dan promo Barberstuff.';

  @override
  String get notificationTimeNow => 'Baru saja';

  @override
  String notificationTimeMinute(int count) {
    return '$count mnt lalu';
  }

  @override
  String notificationTimeHour(int count) {
    return '$count jam lalu';
  }

  @override
  String notificationTimeDay(int count) {
    return '$count hari lalu';
  }

  @override
  String get notificationBookingTitle => 'Jadwal Booking Dikonfirmasi!';

  @override
  String get notificationBookingBody =>
      'Pemesanan Anda untuk layanan cukur di cabang Jati Asih telah dikonfirmasi oleh barber.';

  @override
  String get notificationPointsTitle => 'Poin Member Bertambah!';

  @override
  String get notificationPointsBody =>
      'Anda mendapatkan 150 poin tambahan dari transaksi cukur terakhir Anda. Tingkatkan terus level Anda!';

  @override
  String get notificationMembershipTitle => 'Selamat, Level Member Naik!';

  @override
  String get notificationMembershipBody =>
      'Anda telah mencapai level Premium! Nikmati berbagai keuntungan eksklusif tanpa antre.';

  @override
  String get notificationRecommendationTitle => 'Rekomendasi Gaya Rambut Baru';

  @override
  String get notificationRecommendationBody =>
      'Temukan tren gaya rambut pria terbaru tahun ini yang cocok dengan bentuk wajah Anda.';

  @override
  String get profileTierSilver => 'Silver Member Barberstuff';

  @override
  String get profileTierGold => 'Gold Member Barberstuff';

  @override
  String get profileTierPlatinum => 'Platinum Member';

  @override
  String get profileMenuPersonalInfo => 'Informasi Pribadi';

  @override
  String get profileMenuLanguage => 'Bahasa';

  @override
  String get profileMenuCard => 'Barberstuff Card';

  @override
  String get profileMenuNotification => 'Notifikasi';

  @override
  String get profileMenuHelp => 'Pusat Bantuan';

  @override
  String get profileMenuAbout => 'Tentang Aplikasi';

  @override
  String get profileMenuLogout => 'Keluar';

  @override
  String get profileLogoutTitle => 'Keluar dari akun?';

  @override
  String get profileLogoutMessage =>
      'Anda perlu masuk lagi untuk memakai Barberstuff.';

  @override
  String get languagePageTitle => 'Pilih Bahasa';

  @override
  String get languagePageDescription =>
      'Silakan pilih bahasa yang nyaman bagi Anda untuk menikmati pengalaman terbaik bersama kami.';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageSelectAction => 'Pilih';

  @override
  String get commonCancel => 'Batal';

  @override
  String get cardPageTitle => 'Barberstuff Card';

  @override
  String get cardIdLabel => 'ID User';

  @override
  String get personalInfoTitle => 'Informasi Pribadi';

  @override
  String get personalInfoChangePhoto => 'Ganti Foto Profil';

  @override
  String get personalInfoPhotoFormat => 'Support Format: JPEG, PNG, JPG';

  @override
  String get personalInfoEmailLocked =>
      'Email dipakai untuk masuk dan tidak bisa diubah';

  @override
  String get personalInfoBirthDateLocked =>
      'Tanggal lahir mengikuti data pendaftaran dan tidak bisa diubah';

  @override
  String get personalInfoPasswordTitle => 'Password Saya';

  @override
  String get personalInfoPasswordSubtitle => 'Ganti Password Saya';

  @override
  String get personalInfoPasswordAction => 'Ganti Sekarang';

  @override
  String get personalInfoSave => 'Simpan Perubahan';

  @override
  String get personalInfoSaved => 'Perubahan tersimpan';

  @override
  String get personalInfoPhotoPending =>
      'Nama dan nomor tersimpan. Foto belum ikut tersimpan.';

  @override
  String get helpTitle => 'Pusat Bantuan';

  @override
  String get helpHeadline => 'Butuh Bantuan? Ceritakan Masalah Anda';

  @override
  String get helpSubtitle =>
      'Isi formulir di bawah ini dan tim kami akan menghubungi Anda secepatnya.';

  @override
  String get helpNameLabel => 'Nama';

  @override
  String get helpProblemLabel => 'Ceritakan Masalah Anda';

  @override
  String get helpProblemHint => 'Tulis masalah yang Anda alami';

  @override
  String get helpSubmit => 'Kirim';

  @override
  String get aboutTitle => 'Tentang Aplikasi';

  @override
  String aboutLastUpdated(String date) {
    return 'Terakhir diperbarui: $date';
  }

  @override
  String get aboutIntro =>
      'Dengan mengakses atau menggunakan aplikasi Barberstuff, Anda setuju untuk terikat pada Ketentuan Penggunaan ini.';

  @override
  String get aboutAcceptanceTitle => '1. Penerimaan Ketentuan';

  @override
  String get aboutAcceptanceBody =>
      'Dengan menggunakan Barberstuff, Anda menyatakan telah membaca, memahami, dan menyetujui Ketentuan Penggunaan ini.';

  @override
  String get aboutEligibilityTitle => '2. Kelayakan';

  @override
  String get aboutEligibilityBody =>
      'Anda harus berusia minimal 17 tahun atau memiliki izin dari orang tua maupun wali untuk menggunakan Barberstuff.';

  @override
  String get aboutAccountTitle => '3. Akun Pengguna';

  @override
  String get aboutAccountPoint1 =>
      'Anda bertanggung jawab menjaga kerahasiaan akun Anda';

  @override
  String get aboutAccountPoint2 =>
      'Seluruh informasi yang diberikan harus akurat dan terkini';

  @override
  String get aboutAccountPoint3 =>
      'Barberstuff tidak bertanggung jawab atas akses tidak sah yang disebabkan kelalaian pengguna';

  @override
  String get aboutUsageTitle => '4. Penggunaan Layanan';

  @override
  String get aboutUsageIntro => 'Anda setuju untuk tidak:';

  @override
  String get aboutUsagePoint1 =>
      'Menggunakan Barberstuff untuk tujuan melanggar hukum';

  @override
  String get aboutUsagePoint2 =>
      'Menyalin, menyebarkan, atau mengeksploitasi konten platform tanpa izin';

  @override
  String get aboutUsagePoint3 =>
      'Mengunggah konten yang melanggar hukum atau hak pihak ketiga';

  @override
  String get aboutIpTitle => '5. Hak Kekayaan Intelektual';

  @override
  String get aboutIpBody =>
      'Seluruh konten, sistem, dan desain platform dimiliki oleh Barberstuff. Data dan materi yang dibuat pengguna tetap menjadi milik pengguna.';

  @override
  String get aboutTerminationTitle => '6. Penghentian Akun';

  @override
  String get aboutTerminationBody =>
      'Barberstuff berhak menangguhkan atau menghentikan akun yang melanggar Ketentuan ini.';

  @override
  String get aboutDisclaimerTitle => '7. Penafian';

  @override
  String get aboutDisclaimerBody =>
      'Barberstuff disediakan sebagaimana adanya dan sebagaimana tersedia, tanpa jaminan dalam bentuk apa pun.';

  @override
  String get aboutChangesTitle => '8. Perubahan Ketentuan';

  @override
  String get aboutChangesBody =>
      'Barberstuff dapat memperbarui Ketentuan ini sewaktu-waktu. Penggunaan platform yang berkelanjutan menandakan penerimaan atas Ketentuan yang diperbarui.';

  @override
  String get bookingTitle => 'Booking';

  @override
  String get bookingBranchTitle => 'Pilih Cabang';

  @override
  String bookingStepLabel(int current, int total) {
    return 'LANGKAH $current DARI $total';
  }

  @override
  String get bookingBranchSubtitle =>
      'Tentukan cabang barbershop terdekat kamu';

  @override
  String get bookingScheduleSubtitle => 'Pilih tanggal dan jam yang tersedia';

  @override
  String get bookingBarberSubtitle =>
      'Pilih barber favoritmu atau biarkan kami memilihkan';

  @override
  String get bookingServiceSubtitle => 'Pilih layanan yang kamu inginkan';

  @override
  String get bookingConfirmTitle => 'Konfirmasi Booking';

  @override
  String get bookingConfirmSubtitle =>
      'Harap periksa kembali detail pesanan Anda';

  @override
  String get bookingNextSchedule => 'Lanjut Pilih Jadwal';

  @override
  String get bookingNextBarber => 'Lanjut Pilih Capster';

  @override
  String get bookingNextService => 'Lanjut Pilih Layanan';

  @override
  String get bookingNextConfirm => 'Lanjut Konfirmasi Booking';

  @override
  String get bookingConfirmCta => 'Konfirmasi Pesanan';

  @override
  String get bookingSlotFullNote => 'Slot yang tidak dapat dipilih sudah penuh';

  @override
  String get bookingSlotEmpty => 'Belum ada jam tersedia di tanggal ini.';

  @override
  String get bookingSlotTooSoon => 'Booking minimal 30 menit dari sekarang.';

  @override
  String get bookingTabService => 'Service';

  @override
  String get bookingAvailableToday => 'Tersedia hari ini';

  @override
  String bookingLockRemaining(String time) {
    return 'Sisa waktu $time';
  }

  @override
  String get bookingLockExpired =>
      'Waktu kunci habis. Silakan pilih jadwal lagi.';

  @override
  String get bookingCancelTitle => 'Batalkan booking?';

  @override
  String get bookingCancelMessage =>
      'Slot yang sudah dikunci akan dilepas dan bisa diambil orang lain.';

  @override
  String get bookingCancelConfirm => 'Ya, batalkan';

  @override
  String get bookingReleaseFailed =>
      'Slot barber belum terlepas. Tunggu sebentar lalu tekan Lanjut lagi.';

  @override
  String get bookingCancelKeep => 'Lanjut booking';

  @override
  String get bookingConfirmBranch => 'CABANG';

  @override
  String get bookingConfirmService => 'LAYANAN';

  @override
  String get bookingConfirmBarber => 'BARBER';

  @override
  String get bookingConfirmSchedule => 'WAKTU & TANGGAL';

  @override
  String get bookingPaymentTitle => 'Rincian Pembayaran';

  @override
  String get bookingSubtotal => 'Subtotal';

  @override
  String get bookingAppFee => 'Biaya Layanan Aplikasi';

  @override
  String get bookingTotal => 'Total Pembayaran';

  @override
  String get bookingBarberTitle => 'Pilih Barber';

  @override
  String get bookingTermsHeadline => '📋 Ketentuan Booking Barberstuff';

  @override
  String get bookingTermsIntro =>
      'Untuk memberikan pelayanan terbaik dan menjaga jadwal tetap teratur, setiap pelanggan diharapkan mengikuti ketentuan booking yang berlaku.';

  @override
  String get bookingTermsRulesLabel => '💡 Aturan Booking:';

  @override
  String get bookingTermsRule1 =>
      'Booking dilakukan minimal 1 jam sebelum jadwal kedatangan';

  @override
  String get bookingTermsRule2 =>
      'Pelanggan diharapkan datang sesuai waktu yang telah dipilih';

  @override
  String get bookingTermsRule3 => 'Toleransi keterlambatan maksimal 5 menit';

  @override
  String get bookingTermsRule4 =>
      'Keterlambatan lebih dari 5 menit dapat menyebabkan booking dibatalkan secara otomatis';

  @override
  String get bookingTermsOutro =>
      'Pastikan datang tepat waktu agar proses pelayanan dapat berjalan nyaman dan sesuai jadwal. Terima kasih atas pengertiannya! 😊';

  @override
  String get bookingTermsAgree => 'Saya sudah baca ketentuan';

  @override
  String get bookingNearbyHeadline => 'Pilih Barberstuff Terdekat!';

  @override
  String get bookingSearchHint => 'Ketik disini!';

  @override
  String get bookingViewStore => 'Lihat Toko';

  @override
  String get bookingStoreEmpty => 'Cabang tidak ditemukan.';

  @override
  String get bookingCapsterEmpty => 'Belum ada capster di cabang ini.';

  @override
  String get commonContinue => 'Lanjutkan';

  @override
  String get bookingScheduleTitle => 'Pilih Jadwal';

  @override
  String get bookingServiceTitle => 'Pilih Layanan';

  @override
  String get bookingDateLabel => 'Tanggal';

  @override
  String get bookingTimeLabel => 'Jam';

  @override
  String get bookingSingleServiceLabel => 'Jasa Satuan';

  @override
  String get bookingPackageLabel => 'Paket';

  @override
  String get bookingServiceSingleOnly =>
      'Mohon maaf, layanan hanya menerima satu layanan per booking. Pilih satu dulu, sisanya booking terpisah.';

  @override
  String get bookingServiceEmpty => 'Belum ada layanan tersedia.';

  @override
  String get bookingSuccessTitle => 'Pemesanan Berhasil!';

  @override
  String get bookingSuccessMessage => 'Pemesanan Anda telah berhasil dilakukan';

  @override
  String get bookingSuccessReceipt => 'Lihat Bukti Pesanan';

  @override
  String get bookingSuccessHome => 'Beranda';

  @override
  String get receiptTitle => 'E-Receipt';

  @override
  String get receiptStore => 'Barber/Salon';

  @override
  String get receiptAddress => 'Alamat';

  @override
  String get receiptName => 'Nama';

  @override
  String get receiptPhone => 'No Telepon';

  @override
  String get receiptDate => 'Tgl Booking';

  @override
  String get receiptTime => 'Jam Booking';

  @override
  String get receiptSpecialist => 'Specialist';

  @override
  String get receiptTotal => 'Total Harga';

  @override
  String get receiptDownload => 'Download E-Receipt';

  @override
  String get comingSoonMessage => 'Segera hadir!';

  @override
  String get commonRetry => 'Coba Lagi';

  @override
  String get offlineCachedData => 'Sedang offline — menampilkan data tersimpan';

  @override
  String get permissionNotificationTitle => 'Izinkan notifikasi';

  @override
  String get permissionNotificationMessage =>
      'Aktifkan notifikasi supaya kamu tahu saat booking dikonfirmasi dan poin bertambah.';

  @override
  String get permissionLocationTitle => 'Izinkan lokasi';

  @override
  String get permissionLocationMessage =>
      'Lokasi dipakai untuk mengurutkan cabang dari yang terdekat denganmu.';

  @override
  String get permissionOpenSettings => 'Buka Pengaturan';

  @override
  String get permissionLater => 'Nanti saja';

  @override
  String get permissionLocationOffTitle => 'Nyalakan lokasi';

  @override
  String get permissionLocationOffMessage =>
      'Layanan lokasi di HP kamu sedang mati. Nyalakan dulu supaya jarak cabang bisa dihitung.';

  @override
  String get permissionOpenLocationSettings => 'Nyalakan Lokasi';

  @override
  String get commonUnderstood => 'Oke';

  @override
  String get commonLogout => 'Keluar';

  @override
  String get promoTitle => 'Pilih Promo';

  @override
  String get promoGradeTitle => 'Keuntungan Grade Ini';

  @override
  String get promoTerms => 'S&K Berlaku';

  @override
  String get promoSectionTitle => 'Promo';

  @override
  String get promoSectionSubtitle =>
      'Promo menarik dari barberstuff, untuk pengguna';

  @override
  String get promoRedeemTitle => 'Tukar Poin';

  @override
  String get promoRedeemSubtitle =>
      'Tukarkan poin Anda dengan berbagai voucher menarik.';

  @override
  String get promoClaim => 'Klaim';

  @override
  String get promoClaimReward => 'Klaim Hadiah';

  @override
  String get promoAboutVoucher => 'Tentang Voucher';

  @override
  String get promoClaimed => 'Hadiah berhasil diklaim.';

  @override
  String get promoNotEnoughPoints =>
      'Poin belum cukup untuk menukar hadiah ini.';

  @override
  String promoPoints(String count) {
    return '$count Points';
  }

  @override
  String promoXp(String count) {
    return '$count XP';
  }

  @override
  String promoProgress(String owned, String needed) {
    return '$owned/$needed';
  }
}
