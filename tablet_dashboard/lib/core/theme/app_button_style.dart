import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

class AppButtonStyle {
  const AppButtonStyle._();

  /// Outlined red button ("Tutup Shift Kasir", "Cancel Pesanan").
  static final ButtonStyle dangerOutlined = OutlinedButton.styleFrom(
    foregroundColor: AppColor.danger,
    backgroundColor: AppColor.dangerSoft,
    side: const BorderSide(color: AppColor.danger),
  );

  /// Soft gold button ("+ Tambah", "Tambah Layanan / Paket").
  static final ButtonStyle softGold = TextButton.styleFrom(
    foregroundColor: AppColor.gold,
    backgroundColor: AppColor.goldSoft,
    disabledBackgroundColor: AppColor.surfaceMuted,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
