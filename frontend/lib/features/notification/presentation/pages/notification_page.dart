import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/notification/domain/app_notification.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_empty_state.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_filter_bar.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_search_field.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_text.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_tile.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const double sidePadding = 20;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(AppNotification n, String q, AppLocalizations l10n) {
    if (q.isEmpty) return true;
    final String needle = q.toLowerCase();
    return notificationTitle(n.category, l10n).toLowerCase().contains(needle) ||
        notificationBody(n.category, l10n).toLowerCase().contains(needle);
  }

  static DateTime _dayOf(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _groupLabel(DateTime day, AppLocalizations l10n, String locale) {
    final DateTime today = _dayOf(DateTime.now());
    final int diff = today.difference(day).inDays;

    if (diff == 0) return l10n.notificationToday;
    if (diff == 1) return l10n.notificationYesterday;
    return DateFormat('EEEE, d MMMM, y', locale).format(day);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NotificationProvider p = context.watch<NotificationProvider>();

    final List<AppNotification> searched = p.items
        .where((AppNotification n) => _matches(n, p.query, l10n))
        .toList();

    final int totalCount = searched.length;
    final int unreadCount = searched
        .where((AppNotification n) => !n.isRead)
        .length;

    final List<AppNotification> visible = p.filter == NotificationFilter.unread
        ? searched.where((AppNotification n) => !n.isRead).toList()
        : searched;

    visible.sort(
      (AppNotification a, AppNotification b) =>
          b.createdAt.compareTo(a.createdAt),
    );

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Image.asset(
            AppAssets.backArrowIcon,
            width: 20,
            height: 16,
            fit: BoxFit.contain,
            color: AppColor.ink,
            filterQuality: FilterQuality.medium,
          ),
        ),
        title: Text(
          l10n.notificationTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NotificationPage.sidePadding,
                4,
                NotificationPage.sidePadding,
                0,
              ),
              child: NotificationSearchField(
                controller: _search,
                hint: l10n.notificationSearchHint,
                onChanged: p.setQuery,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NotificationPage.sidePadding,
              ),
              child: NotificationFilterBar(
                filter: p.filter,
                totalCount: totalCount,
                unreadCount: unreadCount,
                allLabel: l10n.notificationFilterAll,
                unreadLabel: l10n.notificationFilterUnread,
                markAllLabel: l10n.notificationMarkAllRead,
                onSelect: p.setFilter,
                onMarkAll: p.markAllRead,
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? NotificationEmptyState(message: l10n.notificationEmpty)
                  : _NotificationList(
                      items: visible,
                      labelOf: (DateTime day) =>
                          _groupLabel(day, l10n, locale),
                      onTap: p.markRead,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.items,
    required this.labelOf,
    required this.onTap,
  });

  final List<AppNotification> items;
  final String Function(DateTime day) labelOf;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    DateTime? current;

    for (final AppNotification item in items) {
      final DateTime day = _NotificationPageState._dayOf(item.createdAt);

      if (current == null || day != current) {
        current = day;
        rows.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
              NotificationPage.sidePadding,
              rows.isEmpty ? 14 : 18,
              NotificationPage.sidePadding,
              2,
            ),
            child: Text(
              labelOf(day),
              style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
            ),
          ),
        );
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NotificationPage.sidePadding,
          ),
          child: Column(
            children: <Widget>[
              NotificationTile(
                notification: item,
                onTap: () => onTap(item.id),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColor.border.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: rows,
    );
  }
}
