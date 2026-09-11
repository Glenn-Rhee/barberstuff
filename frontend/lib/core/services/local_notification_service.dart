import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService();

  static const String channelId = 'barberstuff_general';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  String _channelName = 'Barberstuff';
  String _channelDescription = '';
  bool _ready = false;
  bool _granted = false;
  int _id = 0;

  bool get isGranted => _granted;

  void applyLabels({required String name, required String description}) {
    _channelName = name;
    _channelDescription = description;
  }

  Future<void> _ensureChannel(
    AndroidFlutterLocalNotificationsPlugin android,
  ) async {
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<void> init() async {
    if (_ready) return;

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: darwin),
      );
      _ready = true;
    } on Object catch (error) {
      debugPrint('LocalNotificationService init gagal: $error');
    }
  }

  Future<bool> requestPermission() async {
    if (!_ready) await init();
    if (!_ready) return false;

    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (android != null) {
        await _ensureChannel(android);
        _granted = await android.requestNotificationsPermission() ?? false;
        return _granted;
      }

      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      _granted =
          await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
      return _granted;
    } on Object catch (error) {
      debugPrint('LocalNotificationService izin gagal: $error');
      return false;
    }
  }

  Future<bool> isEnabled() async {
    if (!_ready) await init();
    if (!_ready) return false;

    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return _granted;

      final bool enabled = await android.areNotificationsEnabled() ?? false;
      _granted = enabled;
      return enabled;
    } on Object catch (error) {
      debugPrint('LocalNotificationService cek izin gagal: $error');
      return false;
    }
  }

  Future<void> show({required String title, required String body}) async {
    if (!_ready) await init();
    if (!_ready) return;
    if (!_granted) await requestPermission();

    _id += 1;

    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) await _ensureChannel(android);

      await _plugin.show(
        id: _id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } on Object catch (error) {
      debugPrint('LocalNotificationService show gagal: $error');
    }
  }
}
