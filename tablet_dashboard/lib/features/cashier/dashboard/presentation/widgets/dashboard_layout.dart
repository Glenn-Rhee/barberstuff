import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/dashboard_greeting.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/quick_actions_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/today_stats_row.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/upcoming_bookings_card.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';

// Kerangka dashboard semua role, isi [title] dan [side]
class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key, required this.title, required this.side});

  final String title;
  final List<Widget> side;

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  @override
  void initState() {
    super.initState();
    // Data reservasi dimuat ulang tiap kali dashboard dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DashboardController>().refresh();
    });
  }

  // Tarik ke bawah / tombol muat ulang = hit ulang semua data dashboard
  Future<void> _refreshAll() async {
    final storeId = context.read<StoreController>().storeId;
    await Future.wait([
      context.read<ShiftController>().refresh(),
      context.read<DashboardController>().refresh(),
      context.read<CatalogController>().loadCapsters(),
      context.read<AttendanceController>().load(storeId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final shiftError = context.select<ShiftController, String?>((s) => s.error);
    final name = context.select<SessionController, String>(
      (s) => s.profile?.name ?? '',
    );

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardGreeting(
              title: widget.title,
              name: name,
              onRefresh: _refreshAll,
            ),
            const SizedBox(height: 16),
            if (shiftError != null) ...[
              ErrorBar(message: shiftError, onRetry: _refreshAll),
              const SizedBox(height: 16),
            ],
            const TodayStatsRow(),
            const SizedBox(height: 16),
            const QuickActionsCard(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: UpcomingBookingsCard()),
                const SizedBox(width: 16),
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      for (final (index, card) in widget.side.indexed) ...[
                        if (index > 0) const SizedBox(height: 16),
                        card,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
