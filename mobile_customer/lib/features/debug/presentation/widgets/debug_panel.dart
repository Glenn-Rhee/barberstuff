import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/booking_catalog.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/debug/presentation/widgets/debug_controls.dart';
import 'package:mobile_barberstuff/features/debug/presentation/widgets/debug_permission_section.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
import 'package:mobile_barberstuff/features/notification/domain/entities/app_notification.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> showDebugPanel(BuildContext context) {
  final DebugOverrides overrides = context.read<DebugOverrides>();
  final BookingCatalog catalog = context.read<BookingCatalog>();
  final NotificationProvider notifications = context
      .read<NotificationProvider>();
  final AppCache cache = context.read<AppCache>();
  // Sheet ini digantung di navigator paling atas, jadi provider dari
  // halaman pemanggil tidak ikut kebawa. Dioper ulang satu per satu.
  final DashboardProvider dashboard = context.read<DashboardProvider>();
  final LocalNotificationService notifService = context
      .read<LocalNotificationService>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<DebugOverrides>.value(value: overrides),
        ChangeNotifierProvider<BookingCatalog>.value(value: catalog),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: notifications,
        ),
        Provider<AppCache>.value(value: cache),
        ChangeNotifierProvider<DashboardProvider>.value(value: dashboard),
        Provider<LocalNotificationService>.value(value: notifService),
      ],
      child: const _DebugPanel(),
    ),
  );
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel();

  static const List<int> _pointPresets = <int>[
    0,
    120,
    480,
    750,
    1250,
    2400,
    3600,
  ];

  @override
  Widget build(BuildContext context) {
    final DebugOverrides d = context.watch<DebugOverrides>();
    final BookingCatalog catalog = context.watch<BookingCatalog>();
    final NotificationProvider notif = context.watch<NotificationProvider>();
    final AppCache appCache = context.read<AppCache>();
    final int unread = notif.items
        .where((AppNotification n) => !n.isRead)
        .length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.bug_report_rounded,
                  size: 20,
                  color: AppColor.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Debug Preview', style: AppTextStyle.titleMedium),
                ),
                if (d.isActive)
                  TextButton(
                    onPressed: d.reset,
                    child: Text(
                      'Reset',
                      style: AppTextStyle.labelMedium.copyWith(
                        color: AppColor.danger,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              d.isActive
                  ? 'Menimpa data server sementara. Tidak dikirim ke backend.'
                  : 'Memakai data asli dari server.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
            ),
            const SizedBox(height: 20),

            Text('premium_type', style: AppTextStyle.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                DebugChip(
                  label: 'server',
                  selected: d.tier == null,
                  onTap: () => d.setTier(null),
                ),
                for (final MemberTier tier in MemberTier.values)
                  DebugChip(
                    label: tier.name,
                    color: TierTheme.of(tier).accent,
                    selected: d.tier == tier,
                    onTap: () => d.setTier(tier),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            Row(
              children: <Widget>[
                Expanded(
                  child: Text('member_points', style: AppTextStyle.titleSmall),
                ),
                Text(
                  d.points?.toString() ?? 'server',
                  style: AppTextStyle.titleSmall.copyWith(
                    color: AppColor.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                DebugChip(
                  label: 'server',
                  selected: d.points == null,
                  onTap: () => d.setPoints(null),
                ),
                for (final int value in _pointPresets)
                  DebugChip(
                    label: '$value',
                    selected: d.points == value,
                    onTap: () => d.setPoints(value),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: (d.points ?? 0).clamp(0, 4000).toDouble(),
              max: 4000,
              divisions: 80,
              activeColor: AppColor.orangeLight,
              label: '${d.points ?? 0}',
              onChanged: (double v) => d.setPoints(v.round()),
            ),

            const Divider(height: 32, color: AppColor.border),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Katalog booking',
                    style: AppTextStyle.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: catalog.reset,
                  child: Text(
                    'Reset',
                    style: AppTextStyle.labelMedium.copyWith(
                      color: AppColor.danger,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            DebugCounterRow(
              label: 'Cabang',
              count: catalog.stores.length,
              onAdd: catalog.addStore,
              onRemove: catalog.removeLastStore,
            ),
            const SizedBox(height: 10),
            DebugCounterRow(
              label: 'Capster',
              count: catalog.capsters.length,
              onAdd: catalog.addCapster,
              onRemove: catalog.removeLastCapster,
            ),

            const Divider(height: 32, color: AppColor.border),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Notifikasi', style: AppTextStyle.titleSmall),
                ),
                TextButton(
                  onPressed: notif.reset,
                  child: Text(
                    'Reset',
                    style: AppTextStyle.labelMedium.copyWith(
                      color: AppColor.danger,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${notif.items.length} notifikasi, $unread belum dibaca. '
              'Dummy lokal, tidak menyentuh backend.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                DebugChip(label: 'Kirim 1', selected: false, onTap: notif.push),
                for (final NotificationCategory c
                    in NotificationCategory.values)
                  DebugChip(
                    label: c.name,
                    selected: false,
                    onTap: () => notif.push(c),
                  ),
                DebugChip(
                  label: 'Tandai dibaca',
                  selected: false,
                  onTap: notif.markAllRead,
                ),
                DebugChip(
                  label: 'Kosongkan',
                  color: AppColor.danger,
                  selected: false,
                  onTap: notif.clear,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Simulasi masuk otomatis '
                    '(${NotificationProvider.simulatorInterval.inSeconds} dtk)',
                    style: AppTextStyle.bodyMedium,
                  ),
                ),
                Switch(
                  value: notif.isSimulating,
                  activeThumbColor: AppColor.orangeLight,
                  onChanged: notif.toggleSimulator,
                ),
              ],
            ),

            const Divider(height: 32, color: AppColor.border),
            const DebugPermissionSection(),

            const Divider(height: 32, color: AppColor.border),
            Text('Booking & cache', style: AppTextStyle.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Durasi lock bawaan server 5 menit. Perpendek untuk menguji '
              'countdown habis. Alur booking dibuka ulang agar berlaku.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                DebugChip(
                  label: 'server (5 mnt)',
                  selected: d.lockDuration == null,
                  onTap: () => d.setLockDuration(null),
                ),
                for (final int seconds in <int>[15, 30, 60])
                  DebugChip(
                    label: '\$seconds dtk',
                    selected: d.lockDuration?.inSeconds == seconds,
                    onTap: () => d.setLockDuration(Duration(seconds: seconds)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Paksa mode offline',
                    style: AppTextStyle.bodyMedium,
                  ),
                ),
                Switch(
                  value: d.forceOffline,
                  activeThumbColor: AppColor.danger,
                  onChanged: d.setForceOffline,
                ),
              ],
            ),
            Text(
              d.forceOffline
                  ? 'Semua request ditolak. Halaman yang punya cache tetap '
                        'terbaca dan menampilkan pita offline.'
                  : 'Request berjalan normal ke server.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                DebugChip(
                  label: 'Kosongkan cache',
                  color: AppColor.danger,
                  selected: false,
                  onTap: () => appCache.clearAll(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
