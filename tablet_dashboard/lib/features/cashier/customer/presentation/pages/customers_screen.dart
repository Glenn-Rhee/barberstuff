import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_detail_panel.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_kpi_row.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_table.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/pages/scan_booking_screen.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/widgets/store_selector.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/header_action_button.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/refresh_button.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_tabs.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Halaman Pelanggan: daftar pelanggan + detail & aksi di kanan
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    // Data terbaru tiap halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final history = context.read<CustomerHistoryController>();
      history.refresh(silent: history.all.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CustomerHistoryController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Pelanggan',
            subtitle: 'Kelola informasi dan layanan di setiap cabang.',
            actions: [
              HeaderActionButton(
                icon: AppAsset.scanIcon,
                label: 'Scan Barcode',
                onTap: () => openScanBooking(context),
              ),
              RefreshButton(onRefresh: history.refresh),
              const StoreSelector(),
              const StoreOpenChip(),
            ],
          ),
          const SizedBox(height: 12),
          const PageTabs(tabs: ['Daftar Pelanggan'], selected: 0),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomerKpiRow(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppSearchField(
                              hint: 'Cari nama, nomor HP, atau ID pelanggan...',
                              initialValue: history.query,
                              onChanged: history.setQuery,
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownChip<CustomerFilter>(
                            value: history.filter,
                            options: CustomerFilter.values,
                            labelOf: (f) => f.label,
                            onChanged: history.setFilter,
                          ),
                          const SizedBox(width: 12),
                          DropdownChip<CustomerSort>(
                            value: history.sort,
                            options: CustomerSort.values,
                            labelOf: (s) => s.label,
                            prefix: 'Urutkan: ',
                            onChanged: history.setSort,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Expanded(child: CustomerTable()),
                      const SizedBox(height: 12),
                      PaginationBar(
                        page: history.page - 1,
                        pageCount: history.totalPages,
                        onChanged: (page) => history.setPage(page + 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const SizedBox(width: 300, child: CustomerDetailPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
