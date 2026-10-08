import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';

// Badge Member (pakai aplikasi) / Reguler
class CustomerStatusBadge extends StatelessWidget {
  const CustomerStatusBadge({super.key, required this.customer});

  final CustomerProfile customer;

  @override
  Widget build(BuildContext context) {
    return customer.isMember
        ? const StatusBadge(
            label: 'Member',
            color: AppColor.success,
            background: AppColor.successSoft,
          )
        : const StatusBadge(
            label: 'Reguler',
            color: AppColor.inkSoft,
            background: AppColor.surfaceMuted,
          );
  }
}
