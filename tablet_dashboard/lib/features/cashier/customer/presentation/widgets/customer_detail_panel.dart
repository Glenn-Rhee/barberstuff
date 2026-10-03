import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_section.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/new_reservation_dialog.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Panel kanan halaman Pelanggan: profil, kontak, kunjungan, dan aksi
class CustomerDetailPanel extends StatelessWidget {
  const CustomerDetailPanel({super.key});

  // Pakai pelanggan ini di pesanan langsung
  void _processInCashier(BuildContext context, CustomerProfile customer) {
    context.read<OrderController>().setCustomer(customer);
    context.read<NavigationController>().openOrder(OrderTab.walkIn);
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerHistoryController>().selected;

    return AppCard(
      child: customer == null
          ? const EmptyState(
              icon: Icons.person_outline,
              title: 'Pilih pelanggan',
              message: 'Tap salah satu pelanggan untuk melihat detailnya.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Detail Pelanggan', style: AppTextStyle.title),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(child: _details(customer)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => showNewReservationDialog(context, customer),
                  child: const Text('Buat Reservasi Baru'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _processInCashier(context, customer),
                  child: const Text('Proses di Kasir'),
                ),
              ],
            ),
    );
  }

  Widget _details(CustomerProfile customer) {
    final last = customer.lastVisitedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              PersonAvatar(
                name: customer.name,
                photo: customer.photoUrl,
                size: 64,
              ),
              const SizedBox(height: 8),
              Text(
                customer.name,
                textAlign: TextAlign.center,
                style: AppTextStyle.title,
              ),
              Text(
                customer.code,
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              ),
              const SizedBox(height: 6),
              CustomerStatusBadge(customer: customer),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Field(label: 'Nomor Telepon', value: customer.phone ?? '-'),
        if (customer.email != null)
          _Field(label: 'Email', value: customer.email!),
        if (customer.isMember)
          _Field(
            label: 'Total Poin',
            value: '${PriceFormat.plain(customer.points)} Poin',
            color: AppColor.gold,
          ),
        const Divider(height: 20),
        _Row(label: 'Total Kunjungan', value: '${customer.totalVisited} kali'),
        _Row(
          label: 'Terakhir Datang',
          value: last == null ? '-' : DateFormatId.shortDate(last),
        ),
        _Row(label: 'Layanan Favorit', value: customer.favoriteService ?? '-'),
        _Row(label: 'Barber Favorit', value: customer.favoriteCapster ?? '-'),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(
              fontSize: 10,
              color: AppColor.inkSoft,
            ),
          ),
          Text(value, style: AppTextStyle.bodyBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyle.label,
            ),
          ),
        ],
      ),
    );
  }
}
