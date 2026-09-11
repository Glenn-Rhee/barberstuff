import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/notification/domain/app_notification.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> showDebugPanel(BuildContext context) {
  final DebugOverrides overrides = context.read<DebugOverrides>();
  final BookingCatalog catalog = context.read<BookingCatalog>();
  final NotificationProvider notifications = context
      .read<NotificationProvider>();

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
                _TierChip(
                  label: 'server',
                  selected: d.tier == null,
                  onTap: () => d.setTier(null),
                ),
                for (final MemberTier tier in MemberTier.values)
                  _TierChip(
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
                _TierChip(
                  label: 'server',
                  selected: d.points == null,
                  onTap: () => d.setPoints(null),
                ),
                for (final int value in _pointPresets)
                  _TierChip(
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
            _CounterRow(
              label: 'Cabang',
              count: catalog.stores.length,
              onAdd: catalog.addStore,
              onRemove: catalog.removeLastStore,
            ),
            const SizedBox(height: 10),
            _CounterRow(
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
                _TierChip(
                  label: 'Kirim 1',
                  selected: false,
                  onTap: notif.push,
                ),
                for (final NotificationCategory c
                    in NotificationCategory.values)
                  _TierChip(
                    label: c.name,
                    selected: false,
                    onTap: () => notif.push(c),
                  ),
                _TierChip(
                  label: 'Tandai dibaca',
                  selected: false,
                  onTap: notif.markAllRead,
                ),
                _TierChip(
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
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: AppTextStyle.bodyMedium)),
        _StepButton(icon: Icons.remove_rounded, onTap: onRemove),
        SizedBox(
          width: 44,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: AppTextStyle.titleSmall,
          ),
        ),
        _StepButton(icon: Icons.add_rounded, onTap: onAdd),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColor.ink),
        ),
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? AppColor.inkSoft;

    return Material(
      color: selected ? tint.withValues(alpha: 0.22) : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: selected ? tint : AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
