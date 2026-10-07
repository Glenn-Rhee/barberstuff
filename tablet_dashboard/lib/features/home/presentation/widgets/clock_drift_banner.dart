import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Peringatan kalau jam tablet beda jauh dari jam server. Pesanan langsung
// dan struk sudah pakai jam server, tapi absensi & tanggal di layar masih
// pakai jam tablet
class ClockDriftBanner extends StatelessWidget {
  const ClockDriftBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final clock = context.watch<ServerClock>();
    if (!clock.drifted) return const SizedBox.shrink();

    // offset = jam server - jam tablet, positif = tablet ketinggalan
    final behind = !clock.offset.isNegative;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColor.warningSoft,
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 18, color: AppColor.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Jam tablet ${lengthOf(clock.offset)} lebih '
              '${behind ? 'lambat' : 'cepat'} dari server. Nyalakan '
              'Tanggal & waktu otomatis di Pengaturan tablet supaya absensi '
              'dan tanggal di layar sesuai.',
              style: AppTextStyle.label.copyWith(color: AppColor.warning),
            ),
          ),
        ],
      ),
    );
  }

  // "1 jam 5 menit", "3 menit". Dibulatkan ke menit terdekat, karena
  // header Date cuma sampai detik (1 jam bisa terbaca 59:59)
  static String lengthOf(Duration offset) {
    final minutes = (offset.abs().inSeconds / 60).round();
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return [
      if (hours > 0) '$hours jam',
      if (rest > 0 || hours == 0) '$rest menit',
    ].join(' ');
  }
}
