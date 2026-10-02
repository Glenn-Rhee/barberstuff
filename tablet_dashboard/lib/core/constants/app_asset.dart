// Semua path asset di satu tempat, jangan tulis path manual di widget
class AppAsset {
  const AppAsset._();

  static const String _logo = 'assets/icons/main_logo';
  static const String _sidebar = 'assets/icons/sidebar';
  static const String _cashier = 'assets/icons/cashier';
  static const String _general = 'assets/icons/general';
  static const String _image = 'assets/images';

  // Logo
  static const String logo = '$_logo/logo_barberstuff.png';
  static const String logoForeground = '$_logo/logo_barberstuff_fg.png';
  static const String logoGlyph = '$_logo/logo_glyph.png';

  // Tulisan BARBERSTUFF, dipakai di login dan kepala struk
  static const String logoWordmark = '$_image/logo_wordmark.png';

  // Ikon sidebar (satu warna, diwarnai lewat AppIcon)
  static const String gridIcon = '$_sidebar/grid_when_active.png';
  static const String stackIcon = '$_sidebar/stack_when_unactive.png';
  static const String settingIcon = '$_sidebar/setting.png';

  // Ikon kasir & dashboard
  static const String cartIcon = '$_cashier/cart.png';
  static const String graphicIcon = '$_cashier/graphic.png';
  static const String dateIcon = '$_cashier/date.png';
  static const String personIcon = '$_cashier/person.png';
  static const String scanIcon = '$_cashier/scan.png';
  static const String rightArrowIcon = '$_cashier/right_arrow.png';
  static const String trashIcon = '$_cashier/trash.png';
  static const String cashIcon = '$_cashier/dollar.png';
  static const String cashlessIcon = '$_cashier/non_tunai.png';

  // Ikon layanan di katalog kasir
  static const String beardIcon = '$_cashier/smile.png';
  static const String hairWashIcon = '$_cashier/coffe.png';
  static const String hairStylingIcon = '$_cashier/hairstyling.png';
  static const String creambathIcon = '$_cashier/creambath.png';
  static const String hairColorIcon = '$_cashier/catrambut.png';
  static const String packageIcon = '$_cashier/star.png';
  static const String premiumIcon = '$_cashier/bolt.png';

  // Ikon umum (sama dengan aplikasi customer)
  static const String locationIcon = '$_general/loc.png';
  static const String lockIcon = '$_general/locks.png';
  static const String mailIcon = '$_general/mails.png';
  static const String eyeIcon = '$_general/open_eye.png';
  static const String eyeOffIcon = '$_general/close_eye.png';
  static const String backArrowIcon = '$_general/back_arrow.png';
  static const String searchIcon = '$_general/search.png';
  static const String logoutIcon = '$_general/logout.png';
  static const String scissorsIcon = '$_general/scrissors_book.png';

  // Bintang rating, dua warna jadi jangan diwarnai ulang
  static const String starIcon = '$_general/full_star_history.png';
}
