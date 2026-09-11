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
  String get profileTierSilver => 'Silver Member';

  @override
  String get profileTierGold => 'Gold Member';

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
  String get bookingBranchTitle => 'Pilih Cabang';

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
  String get commonUnderstood => 'Oke';

  @override
  String get commonLogout => 'Keluar';
}
