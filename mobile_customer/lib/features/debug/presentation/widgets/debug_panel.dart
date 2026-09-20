import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/services/permission_prompt.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
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
  final AppCache cache = context.read<AppCache>();
  final BookingJournal journal = context.read<BookingJournal>();
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
        ChangeNotifierProvider<BookingJournal>.value(value: journal),
        ChangeNotifierProvider<DashboardProvider>.value(value: dashboard),
        Provider<LocalNotificationService>.value(value: notifService),
      ],
      child: const _DebugPanel(),
    ),
  );
}

/// Contoh isi jurnal supaya layar riwayat bisa diuji tanpa booking sungguhan.
Future<void> _seedJournal(BookingJournal journal) async {
  final DateTime now = DateTime.now();

  const List<({String service, String store, double price})> samples =
      <({String service, String store, double price})>[
        (service: 'Potong Rambut', store: 'Kemang Raya', price: 95000),
        (service: 'Cukur Jenggot', store: 'Pondok Indah', price: 100000),
        (service: 'Hair Styling', store: 'Ciracas', price: 95000),
      ];

  for (int i = 0; i < samples.length; i++) {
    final sample = samples[i];
    final DateTime at = i == 0
        ? now.add(const Duration(days: 2))
        : now.subtract(Duration(days: 6 * i));

    await journal.add(
      BookingRecord(
        id: 'seed-$i',
        qrCode: 'SEED-$i',
        scheduledAt: at,
        createdAt: now,
        storeId: 'seed-store-$i',
        storeName: sample.store,
        storeAddress: 'Jl. Contoh No. ${i + 1}',
        storePhone: '08123456789',
        capsterId: 'seed-capster-$i',
        capsterName: 'Joni Akbar',
        lines: <BookingLine>[
          BookingLine(
            id: 'seed-svc-$i',
            name: sample.service,
            price: sample.price,
          ),
        ],
        appServiceFee: 0,
        totalPrice: sample.price,
        review: i == 2
            ? const BookingReview(
                capster: 5,
                cashier: 5,
                store: 4,
                message: 'Rapi dan cepat.',
              )
            : null,
      ),
    );
  }
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
    final BookingJournal journal = context.read<BookingJournal>();
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
                _TierChip(label: 'Kirim 1', selected: false, onTap: notif.push),
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

            const Divider(height: 32, color: AppColor.border),
            const _PermissionSection(),

            const Divider(height: 32, color: AppColor.border),
            Text('Riwayat booking', style: AppTextStyle.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Terisi dari booking yang berhasil dan tersimpan di perangkat. '
              'Backend belum punya endpoint riwayat maupun ulasan.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _TierChip(
                  label: 'Isi contoh',
                  selected: false,
                  onTap: () => _seedJournal(journal),
                ),
                _TierChip(
                  label: 'Kosongkan',
                  color: AppColor.danger,
                  selected: false,
                  onTap: journal.clear,
                ),
              ],
            ),

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
                _TierChip(
                  label: 'server (5 mnt)',
                  selected: d.lockDuration == null,
                  onTap: () => d.setLockDuration(null),
                ),
                for (final int seconds in <int>[15, 30, 60])
                  _TierChip(
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
                _TierChip(
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

/// Status izin perangkat, plus tombol untuk menanyakannya ulang.
/// Android hanya bertanya sekali; sesudah dijawab, dialog sistem tidak
/// muncul lagi dan izinnya harus dicabut dari setelan.
class _PermissionSection extends StatefulWidget {
  const _PermissionSection();

  @override
  State<_PermissionSection> createState() => _PermissionSectionState();
}

class _PermissionSectionState extends State<_PermissionSection> {
  LocationPermission? _location;
  bool? _serviceOn;
  bool? _notification;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // context.read tidak boleh dipanggil di dalam initState,
    // jadi pengecekan ditunda sampai frame pertama selesai.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) _refreshStatus();
    });
  }

  Future<void> _refreshStatus() async {
    // Dibaca sebelum await mana pun, supaya context tidak dipakai
    // setelah widget berpotensi lepas dari pohon.
    final LocalNotificationService service = context
        .read<LocalNotificationService>();

    LocationPermission? permission;
    bool? serviceOn;
    bool? notification;

    try {
      permission = await Geolocator.checkPermission();
      serviceOn = await Geolocator.isLocationServiceEnabled();
    } on Object catch (error) {
      debugPrint('Debug panel cek lokasi gagal: $error');
    }

    try {
      notification = await service.isEnabled();
    } on Object catch (error) {
      debugPrint('Debug panel cek notifikasi gagal: $error');
    }

    if (!mounted) return;
    setState(() {
      _location = permission;
      _serviceOn = serviceOn;
      _notification = notification;
    });
  }

  /// Buka lagi kunci dialog internal, tanyakan ulang, lalu hitung ulang jarak.
  Future<void> _askAgain() async {
    if (_busy) return;
    setState(() => _busy = true);

    PermissionPrompt.allowDialogsAgain();

    await PermissionPrompt.askNotification(context);
    if (!mounted) return;
    await PermissionPrompt.askLocation(context);
    if (!mounted) return;

    await context.read<DashboardProvider>().refreshLocation();
    if (!mounted) return;

    setState(() => _busy = false);
    await _refreshStatus();
  }

  Future<void> _openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } on Object catch (error) {
      debugPrint('Debug panel buka setelan gagal: $error');
    }
  }

  String get _locationLabel {
    switch (_location) {
      case null:
        return 'memeriksa...';
      case LocationPermission.always:
        return 'diizinkan selalu';
      case LocationPermission.whileInUse:
        return 'diizinkan saat dipakai';
      case LocationPermission.denied:
        return 'belum dijawab / ditolak sekali';
      case LocationPermission.deniedForever:
        return 'ditolak permanen, hanya bisa lewat setelan';
      case LocationPermission.unableToDetermine:
        return 'tidak terbaca';
    }
  }

  String get _serviceLabel {
    final bool? on = _serviceOn;
    if (on == null) return 'tidak terbaca';
    return on ? 'menyala' : 'mati';
  }

  String get _notificationLabel {
    final bool? on = _notification;
    if (on == null) return 'memeriksa...';
    return on ? 'diizinkan' : 'ditolak';
  }

  @override
  Widget build(BuildContext context) {
    final bool blocked = _location == LocationPermission.deniedForever;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Izin perangkat', style: AppTextStyle.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Lokasi: $_locationLabel\n'
          'GPS perangkat: $_serviceLabel\n'
          'Notifikasi: $_notificationLabel',
          style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
        ),
        if (blocked) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Sudah ditolak permanen. Dialog sistem tidak akan muncul lagi, '
            'cabut izinnya dari setelan aplikasi dulu.',
            style: AppTextStyle.bodySmall.copyWith(color: AppColor.danger),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _TierChip(
              label: _busy ? 'menanya...' : 'Tanya ulang',
              selected: false,
              onTap: _askAgain,
            ),
            _TierChip(
              label: 'Buka setelan aplikasi',
              selected: false,
              onTap: _openSettings,
            ),
            _TierChip(
              label: 'Muat status',
              selected: false,
              onTap: _refreshStatus,
            ),
          ],
        ),
      ],
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
