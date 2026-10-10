import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/widgets/customer_status_badge.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';

// Data Pelanggan: kartu dari histori, atau isi nama + no HP baru
class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  State<CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  Timer? _debounce;
  CustomerProfile? _match;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Cari pelanggan lama setelah kasir berhenti mengetik no HP
  void _onPhoneChanged(String value) {
    context.read<OrderController>().touch();
    _debounce?.cancel();
    setState(() => _match = null);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      final history = context.read<CustomerHistoryController>();
      final found = await history.findByPhone(value);
      if (mounted) setState(() => _match = found);
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderController>();
    final customer = order.customer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Data Pelanggan', style: AppTextStyle.bodyBold),
            ),
            TextButton(
              onPressed: order.clearAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColor.danger,
                visualDensity: VisualDensity.compact,
                textStyle: AppTextStyle.label,
              ),
              child: const Text('Hapus Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (customer != null)
          _ProfileCard(customer: customer, onClear: order.clearCustomer)
        else ...[
          TextField(
            controller: order.nameController,
            style: AppTextStyle.body,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nama Pelanggan'),
            onChanged: (_) => order.touch(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: order.phoneController,
            style: AppTextStyle.body,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              LengthLimitingTextInputFormatter(OrderController.maxPhone),
            ],
            decoration: const InputDecoration(hintText: 'Nomor Telepon'),
            onChanged: _onPhoneChanged,
          ),
          if (_match != null) ...[
            const SizedBox(height: 8),
            _MatchTile(
              customer: _match!,
              onUse: () {
                order.setCustomer(_match!);
                setState(() => _match = null);
              },
            ),
          ],
        ],
      ],
    );
  }
}

// Kartu profil pelanggan yang dipilih dari histori
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.customer, required this.onClear});

  final CustomerProfile customer;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          PersonAvatar(name: customer.name, photo: customer.photoUrl, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.title,
                ),
                Text(
                  customer.code,
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
                const SizedBox(height: 4),
                CustomerStatusBadge(customer: customer),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ganti pelanggan',
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18, color: AppColor.inkSoft),
          ),
        ],
      ),
    );
  }
}

// Saran pelanggan lama dengan no HP yang sama
class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.customer, required this.onUse});

  final CustomerProfile customer;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColor.goldSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.goldBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pelanggan lama: ${customer.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.label,
                ),
                Text(
                  '${customer.statusLabel} · ${customer.totalVisited}x datang',
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onUse, child: const Text('Pakai')),
        ],
      ),
    );
  }
}
