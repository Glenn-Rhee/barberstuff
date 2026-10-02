import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/printer/bluetooth_printer.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/services/printer/test_print.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/settings/presentation/widgets/printer_picker_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/shift_status_chip.dart';
import 'package:tablet_dashboard/shared/dialogs/print_with_retry.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';

// Halaman Konfigurasi: atur printer struk
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickPrinter(BuildContext context) async {
    final printer = context.read<PrinterController>();
    final device = await showDialog<PrinterDevice>(
      context: context,
      builder: (_) => PrinterPickerDialog(controller: printer),
    );
    if (device == null || !context.mounted) return;
    try {
      await printer.connect(device);
      if (context.mounted) {
        AppToast.show(context, 'Terhubung ke ${device.name}');
      }
    } on PrinterException catch (e) {
      if (context.mounted) AppToast.show(context, e.message, error: true);
    }
  }

  Future<void> _testPrint(BuildContext context) async {
    final name = context.read<PrinterController>().selected?.name ?? '-';
    final page = buildTestPrint(
      printerName: name,
      now: DateTime.now(),
      logo: ReceiptLogo.cached,
    );
    final printed = await printWithRetry(context, page);
    if (printed && context.mounted) {
      AppToast.show(context, 'Test print terkirim ke $name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = context.watch<PrinterController>();
    final device = printer.selected;
    final (color, status) = switch (printer.status) {
      PrinterStatus.disconnected => (AppColor.inkFaint, 'Belum terhubung'),
      PrinterStatus.connecting => (AppColor.gold, 'Menghubungkan…'),
      PrinterStatus.connected => (AppColor.success, 'Terhubung'),
      PrinterStatus.printing => (AppColor.gold, 'Mencetak…'),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Konfigurasi',
            subtitle: 'Atur printer struk dan perangkat kasir.',
            actions: [ShiftStatusChip()],
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColor.goldSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.print_outlined,
                          color: AppColor.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Printer Struk', style: AppTextStyle.title),
                          Text(
                            'Panda PRJ-R58D · kertas 58mm · Bluetooth',
                            style: AppTextStyle.caption.copyWith(
                              color: AppColor.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: device == null ? AppColor.danger : color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        device?.name ?? 'Belum ada printer',
                        style: AppTextStyle.bodyBold,
                      ),
                      if (device != null)
                        Text(
                          '  ·  $status',
                          style: AppTextStyle.body.copyWith(
                            color: AppColor.inkSoft,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: printer.busy
                            ? null
                            : () => _pickPrinter(context),
                        icon: const Icon(Icons.bluetooth, size: 18),
                        label: const Text('Pilih Printer'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: printer.busy
                            ? null
                            : () => _testPrint(context),
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text('Test Print'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColor.goldSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cara menghubungkan',
                          style: AppTextStyle.label,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1. Nyalakan printer (lampu biru berkedip = siap di-pair).\n'
                          '2. Buka Pengaturan > Bluetooth tablet, pair ke '
                          '"${PrinterController.defaultPrinterName}" dengan PIN 0000.\n'
                          '3. Kembali ke sini, tekan Pilih Printer.\n'
                          '4. Tekan Test Print untuk memastikan hasil cetak.',
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
