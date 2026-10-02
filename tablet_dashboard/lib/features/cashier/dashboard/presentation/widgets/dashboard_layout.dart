import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/dashboard_greeting.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/quick_actions_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/today_stats_row.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/upcoming_bookings_card.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';

// Kerangka dashboard yang dipakai kasir, admin, dan mitra.
// Tiap role tinggal isi [title] dan kartu di kolom kanan ([side])
class DashboardLayout extends StatelessWidget {
  const DashboardLayout({super.key, required this.title, required this.side});

  final String title;
  final List<Widget> side;

  // Muat ulang shift, booking, dan capster
  static void refresh(BuildContext context) {
    context.read<ShiftController>().refresh();
    context.read<BookingsController>().refresh();
    context.read<CatalogController>().loadCapsters();
  }

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final name = context.select<SessionController, String>(
      (s) => s.profile?.name ?? '',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardGreeting(
            title: title,
            name: name,
            onRefresh: () => refresh(context),
          ),
          const SizedBox(height: 16),
          if (shift.error != null) ...[
            ErrorBar(message: shift.error!, onRetry: () => refresh(context)),
            const SizedBox(height: 16),
          ],
          TodayStatsRow(session: shift.session),
          const SizedBox(height: 16),
          const QuickActionsCard(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: UpcomingBookingsCard()),
              const SizedBox(width: 16),
              SizedBox(
                width: 340,
                child: Column(
                  children: [
                    for (final (index, card) in side.indexed) ...[
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
    );
  }
}
