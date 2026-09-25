import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation_controller.dart';
import '../../../../app/scan_barcode.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/store_widgets.dart';
import '../../../reservation/presentation/widgets/bookings_view.dart';
import '../widgets/walk_in_view.dart';

/// Width of the right-hand panel (order / booking detail).
const kasirPanelWidth = 336.0;

class KasirPage extends StatelessWidget {
  const KasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Kasir',
            subtitle: 'Layanan dan booking toko Anda.',
            actions: [
              OutlinedButton.icon(
                onPressed: () => scanBarcode(context),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Scan QR'),
              ),
              const ShiftStatusChip(),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: switch (nav.kasirTab) {
              KasirTab.langsung => const WalkInView(),
              KasirTab.reservasi => const BookingsView(),
            },
          ),
        ],
      ),
    );
  }
}

class KasirTabs extends StatelessWidget {
  const KasirTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    return Row(
      children: [
        Pill(
          label: 'Pesanan Langsung',
          selected: nav.kasirTab == KasirTab.langsung,
          onTap: () => nav.openKasir(KasirTab.langsung),
        ),
        const SizedBox(width: 8),
        Pill(
          label: 'Dari Reservasi',
          selected: nav.kasirTab == KasirTab.reservasi,
          onTap: () => nav.openKasir(KasirTab.reservasi),
        ),
      ],
    );
  }
}
