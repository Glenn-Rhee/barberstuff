import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/message_box.dart';

// Buka scan QR, berhasil = pindah ke Dari Reservasi dengan booking terpilih
Future<void> openScanBooking(
  BuildContext context, {
  String? initialCode,
}) async {
  final nav = context.read<NavigationController>();
  final bookings = context.read<BookingsController>();
  final bookingId = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (_) => ScanBookingScreen(initialCode: initialCode),
    ),
  );
  if (bookingId == null || !context.mounted) return;
  AppToast.show(context, 'Check-in berhasil, lanjut ke pembayaran');
  nav.openOrder(OrderTab.reservation);
  await bookings.focus(bookingId);
}

// Scan QR "bk{id}" lalu check-in (QR aplikasi pelanggan: 4 karakter awal id).
// Bisa juga diketik / scanner USB
class ScanBookingScreen extends StatefulWidget {
  const ScanBookingScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<ScanBookingScreen> createState() => _ScanBookingScreenState();
}

class _ScanBookingScreenState extends State<ScanBookingScreen> {
  final _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  late final _manual = TextEditingController(text: widget.initialCode);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _scanner.dispose();
    _manual.dispose();
    super.dispose();
  }

  Future<void> _checkIn(String raw) async {
    final code = raw.trim();
    if (code.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<BookingsController>().checkIn(code);
    if (!mounted) return;
    if (error == null) {
      // Balikin id / awalan id booking (tanpa "bk") untuk dipilih
      Navigator.pop(context, code.startsWith('bk') ? code.substring(2) : code);
      return;
    }
    setState(() {
      _busy = false;
      _error = '$error\nKode: $code';
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.map((b) => b.rawValue).nonNulls.firstOrNull;
    if (code != null) _checkIn(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _camera()),
              const SizedBox(width: 24),
              SizedBox(width: 380, child: _panel()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _camera() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            errorBuilder: (_, error) => _CameraError(error: error),
          ),
          // Bingkai area scan
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.gold, width: 3),
              ),
            ),
          ),
          if (_busy)
            ColoredBox(
              color: AppColor.ink.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColor.gold),
                    const SizedBox(height: 12),
                    Text(
                      'Memproses check-in…',
                      style: AppTextStyle.bodyBold.copyWith(
                        color: AppColor.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Row(
              children: [
                _CameraButton(
                  icon: Icons.flash_on,
                  tooltip: 'Nyalakan / matikan lampu',
                  onTap: _scanner.toggleTorch,
                ),
                const SizedBox(width: 12),
                _CameraButton(
                  icon: Icons.cameraswitch_outlined,
                  tooltip: 'Ganti kamera depan / belakang',
                  onTap: _scanner.switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy ? null : () => Navigator.pop(context),
                icon: const AppIcon(AppAsset.backArrowIcon, size: 16),
                label: const Text('Kembali'),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Scan QR Booking', style: AppTextStyle.h2),
            const SizedBox(height: 4),
            Text(
              'Minta pelanggan membuka QR booking di aplikasi Barberstuff, '
              'lalu arahkan ke kamera tablet.',
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
            const SizedBox(height: 16),
            for (final (index, step) in const [
              'QR terbaca otomatis, tidak perlu tekan tombol',
              'Booking berubah jadi "Sudah Check-in"',
              'Lanjut bayar di Kasir > Dari Reservasi',
            ].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColor.goldSoft,
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyle.label.copyWith(
                          color: AppColor.gold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(step, style: AppTextStyle.body)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Atau ketik kode booking / pakai scanner USB',
              style: AppTextStyle.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _manual,
              enabled: !_busy,
              style: AppTextStyle.body,
              decoration: const InputDecoration(hintText: 'bk…'),
              onSubmitted: _checkIn,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : () => _checkIn(_manual.text),
              icon: const AppIcon(AppAsset.personIcon, size: 18),
              label: const Text('Check-in'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              MessageBox(message: _error!),
            ],
          ],
        ),
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: AppColor.ink.withValues(alpha: 0.6),
        foregroundColor: AppColor.surface,
      ),
      icon: Icon(icon),
    );
  }
}

// Kamera gagal dibuka: izin ditolak / perangkat tidak didukung
class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Izin kamera ditolak, aktifkan di Pengaturan.',
      MobileScannerErrorCode.unsupported =>
        'Perangkat ini tidak punya kamera yang didukung.',
      _ => 'Kamera tidak bisa dibuka (${error.errorCode.name}).',
    };

    return ColoredBox(
      color: AppColor.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                size: 48,
                color: AppColor.sidebarMuted,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(color: AppColor.surface),
              ),
              const SizedBox(height: 4),
              Text(
                'Kode booking tetap bisa diketik di panel kanan.',
                textAlign: TextAlign.center,
                style: AppTextStyle.caption.copyWith(
                  color: AppColor.sidebarMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
