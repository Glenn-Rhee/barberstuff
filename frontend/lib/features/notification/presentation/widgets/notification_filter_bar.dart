import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.filter,
    required this.totalCount,
    required this.unreadCount,
    required this.allLabel,
    required this.unreadLabel,
    required this.markAllLabel,
    required this.onSelect,
    required this.onMarkAll,
  });

  final NotificationFilter filter;
  final int totalCount;
  final int unreadCount;
  final String allLabel;
  final String unreadLabel;
  final String markAllLabel;
  final ValueChanged<NotificationFilter> onSelect;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _FilterChip(
                  label: allLabel,
                  count: totalCount,
                  active: filter == NotificationFilter.all,
                  onTap: () => onSelect(NotificationFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: unreadLabel,
                  count: unreadCount,
                  active: filter == NotificationFilter.unread,
                  onTap: () => onSelect(NotificationFilter.unread),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onMarkAll,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              markAllLabel,
              maxLines: 1,
              style: AppTextStyle.labelSmall.copyWith(
                fontSize: 11,
                color: AppColor.goldDeep,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? AppColor.goldSoft.withValues(alpha: 0.55)
          : AppColor.border.withValues(alpha: 0.4),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? AppColor.goldMid
                      : AppColor.goldMid.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  maxLines: 1,
                  style: AppTextStyle.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
