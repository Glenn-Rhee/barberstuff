import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_section.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tabel daftar pelanggan, tap baris / Detail = tampil di panel kanan
class CustomerTable extends StatelessWidget {
  const CustomerTable({super.key});

  static const _flex = [5, 4, 3, 3, 3, 3, 2];

  static Widget _cells(List<Widget> children) => Row(
    children: [
      for (final (i, child) in children.indexed)
        Expanded(
          flex: _flex[i],
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CustomerHistoryController>();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _cells([
              for (final label in const [
                'PELANGGAN',
                'NOMOR TELEPON',
                'STATUS',
                'SUMBER DATA',
                'TOTAL KUNJUNGAN',
                'TERAKHIR DATANG',
                'AKSI',
              ])
                Text(
                  label,
                  style: AppTextStyle.label.copyWith(
                    fontSize: 10,
                    color: AppColor.inkSoft,
                  ),
                ),
            ]),
          ),
          const Divider(),
          Expanded(child: _body(history)),
        ],
      ),
    );
  }

  Widget _body(CustomerHistoryController history) {
    if (history.loading && history.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (history.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat pelanggan',
        message: history.error!,
        onRetry: history.refresh,
      );
    }
    final customers = history.customers;
    if (customers.isEmpty) {
      return EmptyState(
        icon: Icons.person_search_outlined,
        title: 'Pelanggan tidak ditemukan',
        message: history.all.isEmpty
            ? 'Pelanggan baru tersimpan otomatis setelah pesanan dibuat.'
            : 'Coba kata kunci atau filter lain.',
      );
    }

    return RefreshIndicator(
      onRefresh: history.refresh,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          for (final customer in customers)
            _CustomerRow(
              customer: customer,
              selected: history.selectedId == customer.id,
              onTap: () => history.select(customer),
            ),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.customer,
    required this.selected,
    required this.onTap,
  });

  final CustomerProfile customer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = customer.lastVisitedAt;
    final text = AppTextStyle.body.copyWith(fontSize: 12);

    return Material(
      color: selected ? AppColor.goldSoft : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColor.goldBorder : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: selected
              ? null
              : const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColor.border)),
                ),
          child: CustomerTable._cells([
            Row(
              children: [
                PersonAvatar(
                  name: customer.name,
                  photo: customer.photoUrl,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyBold.copyWith(fontSize: 12),
                      ),
                      Text(
                        customer.code,
                        style: AppTextStyle.caption.copyWith(
                          fontSize: 10,
                          color: AppColor.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(customer.phone ?? '-', style: text),
            CustomerStatusBadge(customer: customer),
            Text(customer.sourceLabel, style: text),
            Text('${customer.totalVisited} kali', style: text),
            Text(
              last == null ? '-' : DateFormatId.compactDate(last),
              style: text,
            ),
            SizedBox(
              height: 30,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: AppTextStyle.label,
                ),
                child: const Text('Detail'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
