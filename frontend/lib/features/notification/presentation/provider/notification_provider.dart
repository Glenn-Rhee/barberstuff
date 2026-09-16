import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/features/notification/domain/app_notification.dart';

typedef NotificationPresenter = void Function(AppNotification notification);

enum NotificationFilter { all, unread }

class NotificationProvider extends ChangeNotifier {
  NotificationProvider() {
    _items = _seed();
  }

  static const Duration simulatorInterval = Duration(seconds: 8);

  late List<AppNotification> _items;
  NotificationFilter _filter = NotificationFilter.all;
  String _query = '';
  Timer? _simulator;
  NotificationPresenter? _presenter;
  int _serial = 0;

  List<AppNotification> get items => List<AppNotification>.unmodifiable(_items);
  NotificationFilter get filter => _filter;
  String get query => _query;
  bool get isSimulating => _simulator != null;

  static List<AppNotification> _seed() {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));

    return <AppNotification>[
      AppNotification(
        id: 'seed-1',
        category: NotificationCategory.booking,
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      AppNotification(
        id: 'seed-2',
        category: NotificationCategory.points,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'seed-3',
        category: NotificationCategory.membership,
        createdAt: yesterday,
      ),
      AppNotification(
        id: 'seed-4',
        category: NotificationCategory.points,
        createdAt: yesterday.subtract(const Duration(minutes: 20)),
      ),
      AppNotification(
        id: 'seed-5',
        category: NotificationCategory.booking,
        createdAt: yesterday.subtract(const Duration(minutes: 40)),
      ),
      AppNotification(
        id: 'seed-6',
        category: NotificationCategory.recommendation,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  void attachPresenter(NotificationPresenter? presenter) {
    _presenter = presenter;
  }

  void setFilter(NotificationFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void setQuery(String value) {
    final String next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void markRead(String id) {
    bool changed = false;
    _items = _items.map((AppNotification n) {
      if (n.id != id || n.isRead) return n;
      changed = true;
      return n.copyWith(isRead: true);
    }).toList();
    if (changed) notifyListeners();
  }

  void markAllRead() {
    if (_items.every((AppNotification n) => n.isRead)) return;
    _items = _items
        .map((AppNotification n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  void push([NotificationCategory? category]) {
    _serial += 1;
    final List<NotificationCategory> all = NotificationCategory.values;
    final NotificationCategory picked = category ?? all[_serial % all.length];

    final AppNotification created = AppNotification(
      id: 'sim-$_serial',
      category: picked,
      createdAt: DateTime.now(),
    );

    _items = <AppNotification>[created, ..._items];
    notifyListeners();
    _presenter?.call(created);
  }

  void clear() {
    if (_items.isEmpty) return;
    _items = <AppNotification>[];
    notifyListeners();
  }

  void reset() {
    stopSimulator();
    _items = _seed();
    _filter = NotificationFilter.all;
    _query = '';
    _serial = 0;
    notifyListeners();
  }

  void startSimulator() {
    if (_simulator != null) return;
    _simulator = Timer.periodic(simulatorInterval, (Timer _) => push());
    notifyListeners();
  }

  void stopSimulator() {
    if (_simulator == null) return;
    _simulator!.cancel();
    _simulator = null;
    notifyListeners();
  }

  void toggleSimulator(bool on) {
    if (on) {
      startSimulator();
    } else {
      stopSimulator();
    }
  }

  @override
  void dispose() {
    _simulator?.cancel();
    _simulator = null;
    super.dispose();
  }
}
