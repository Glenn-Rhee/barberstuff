import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/login/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Kartu akun yang sedang login: nama, role, dan email
class StaffProfileCard extends StatelessWidget {
  const StaffProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select<SessionController, StaffProfile?>(
      (s) => s.profile,
    );
    if (profile == null) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Akun', style: AppTextStyle.title),
          const SizedBox(height: 12),
          Row(
            children: [
              PersonAvatar(name: profile.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodyBold,
                    ),
                    Text(
                      profile.roleLabel,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.gold,
                      ),
                    ),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
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
