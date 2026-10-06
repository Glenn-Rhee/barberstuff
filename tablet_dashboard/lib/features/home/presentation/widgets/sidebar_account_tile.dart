import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';

// Akun yang login + tombol keluar di bawah sidebar
class SidebarAccountTile extends StatelessWidget {
  const SidebarAccountTile({
    super.key,
    required this.profile,
    required this.expanded,
    required this.onSignOut,
  });

  final StaffProfile profile;
  final bool expanded;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    // Teks saja (tanpa ikon) supaya jelas fungsinya, selebar sidebar
    final signOut = SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onSignOut,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.surface,
          side: const BorderSide(color: AppColor.sidebarDivider),
          minimumSize: const Size(0, 36),
          padding: EdgeInsets.zero,
          backgroundColor: AppColor.danger,
        ),
        child: const Text('Keluar'),
      ),
    );

    if (!expanded) {
      return Column(
        children: [
          PersonAvatar(name: profile.name, size: 36),
          const SizedBox(height: 12),
          signOut,
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            PersonAvatar(name: profile.name, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyBold.copyWith(
                      color: AppColor.surface,
                    ),
                  ),
                  Text(
                    profile.roleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.sidebarMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        signOut,
      ],
    );
  }
}
