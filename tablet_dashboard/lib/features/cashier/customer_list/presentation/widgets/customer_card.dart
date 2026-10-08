import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/widgets/customer_status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Kartu satu pelanggan di histori + tombol pilih untuk pesanan
class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.selected,
    required this.onSelect,
  });

  final CustomerProfile customer;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final last = customer.lastVisitedAt;

    return AppCard(
      color: selected ? AppColor.goldSoft : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PersonAvatar(name: customer.name, photo: customer.photoUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodyBold,
                    ),
                    Text(
                      customer.code,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomerStatusBadge(customer: customer),
          ),
          const SizedBox(height: 8),
          // Isi tengah bisa digulir, tombol pilih tetap kelihatan
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Row(label: 'Telepon', value: customer.phone ?? '-'),
                  _Row(
                    label: 'Kunjungan',
                    value: customer.totalVisited == 0
                        ? 'Belum pernah selesai'
                        : '${customer.totalVisited}x',
                  ),
                  _Row(
                    label: 'Terakhir',
                    value: last == null ? '-' : DateFormatId.dateTime(last),
                  ),
                  if (customer.isMember)
                    _Row(
                      label: 'Poin',
                      value: '${PriceFormat.plain(customer.points)} poin',
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAVORIT',
                          style: AppTextStyle.label.copyWith(
                            fontSize: 10,
                            color: AppColor.inkSoft,
                          ),
                        ),
                        _Row(
                          label: 'Layanan',
                          value: customer.favoriteService ?? '-',
                        ),
                        _Row(
                          label: 'Capster',
                          value: customer.favoriteCapster ?? '-',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: FilledButton(
              onPressed: selected ? null : onSelect,
              child: Text(selected ? 'Sedang dipilih' : 'Pilih Pelanggan'),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(
            '$label:',
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
