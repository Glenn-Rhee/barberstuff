import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/widgets/attendance_card.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';

// Buka halaman absensi karyawan (capster) hari ini
Future<void> openAttendance(BuildContext context) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AttendanceScreen()),
);

// Absensi capster hari ini. Capster yang tidak hadir tidak bisa dipilih di Kasir
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  Future<void> _markAllPresent(BuildContext context) async {
    final attendance = context.read<AttendanceController>();
    final capsters = context.read<CatalogController>().activeCapsters;
    final pending = [
      for (final capster in capsters)
        if (attendance.entryOf(capster.id) == null) capster.id,
    ];
    if (pending.isEmpty) {
      AppToast.show(context, 'Semua capster sudah diabsen');
      return;
    }
    await attendance.markAll(pending, AttendanceStatus.present);
    if (context.mounted) {
      AppToast.show(context, '${pending.length} capster ditandai hadir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final attendance = context.watch<AttendanceController>();
    final storeName = context.select<StoreController, String>(
      (s) => s.current?.displayName ?? '-',
    );
    final capsters = catalog.activeCapsters;
    final summary = attendance.summaryOf(capsters);

    return Scaffold(
      backgroundColor: AppColor.surfaceSubtle,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Absensi Karyawan',
                subtitle:
                    '${DateFormatId.longDate(attendance.day)} · $storeName',
                onBack: () => Navigator.pop(context),
                actions: [
                  OutlinedButton.icon(
                    onPressed: capsters.isEmpty
                        ? null
                        : () => _markAllPresent(context),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Tandai Sisanya Hadir'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Hadir',
                      value: summary.present,
                      color: AppColor.success,
                      background: AppColor.successSoft,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Tidak Hadir',
                      value: summary.absent,
                      color: AppColor.danger,
                      background: AppColor.dangerSoft,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Belum Absen',
                      value: summary.pending,
                      color: AppColor.inkSoft,
                      background: AppColor.surfaceMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(child: _body(context, catalog, attendance)),
              const SizedBox(height: 12),
              Text(
                'Absensi tersimpan di tablet ini untuk hari ini. Capster yang '
                'tidak hadir tidak muncul di pilihan capster Kasir.',
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    CatalogController catalog,
    AttendanceController attendance,
  ) {
    if (catalog.loadingCapsters) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.capsterError != null) {
      return ErrorRetryView(
        title: 'Gagal memuat capster',
        message: catalog.capsterError!,
        onRetry: catalog.loadCapsters,
      );
    }
    final capsters = catalog.activeCapsters;
    if (capsters.isEmpty) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        title: 'Belum ada capster aktif',
        message: 'Capster toko ditambahkan oleh admin.',
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 210,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: capsters.length,
      itemBuilder: (_, index) {
        final capster = capsters[index];
        return AttendanceCard(
          capster: capster,
          entry: attendance.entryOf(capster.id),
          onMark: (status) => attendance.mark(capster.id, status),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final int value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: AppTextStyle.title.copyWith(color: color),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyle.bodyMedium),
        ],
      ),
    );
  }
}
