import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/debug/presentation/widgets/debug_controls.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
import 'package:mobile_barberstuff/shared/dialogs/permission_prompt.dart';
import 'package:provider/provider.dart';

/// Status izin perangkat, plus tombol untuk menanyakannya ulang.
/// Android hanya bertanya sekali; sesudah dijawab, dialog sistem tidak
/// muncul lagi dan izinnya harus dicabut dari setelan.
class DebugPermissionSection extends StatefulWidget {
  const DebugPermissionSection({super.key});

  @override
  State<DebugPermissionSection> createState() => _DebugPermissionSectionState();
}

class _DebugPermissionSectionState extends State<DebugPermissionSection> {
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
            DebugChip(
              label: _busy ? 'menanya...' : 'Tanya ulang',
              selected: false,
              onTap: _askAgain,
            ),
            DebugChip(
              label: 'Buka setelan aplikasi',
              selected: false,
              onTap: _openSettings,
            ),
            DebugChip(
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
