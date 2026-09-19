import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';

class DebugOverrides extends ChangeNotifier {
  MemberTier? _tier;
  int? _points;
  Duration? _lockDuration;
  bool _forceOffline = false;

  MemberTier? get tier => _tier;
  int? get points => _points;
  Duration? get lockDuration => _lockDuration;
  bool get forceOffline => _forceOffline;

  bool get isActive =>
      _tier != null ||
      _points != null ||
      _lockDuration != null ||
      _forceOffline;

  void setTier(MemberTier? value) {
    if (_tier == value) return;
    _tier = value;
    notifyListeners();
  }

  void setPoints(int? value) {
    if (_points == value) return;
    _points = value;
    notifyListeners();
  }

  void setLockDuration(Duration? value) {
    if (_lockDuration == value) return;
    _lockDuration = value;
    notifyListeners();
  }

  void setForceOffline(bool value) {
    if (_forceOffline == value) return;
    _forceOffline = value;
    notifyListeners();
  }

  void reset() {
    if (!isActive) return;
    _tier = null;
    _points = null;
    _lockDuration = null;
    _forceOffline = false;
    notifyListeners();
  }

  CustomerProfile? apply(CustomerProfile? profile) {
    if (profile == null || !isActive) return profile;
    return profile.copyWith(tier: _tier, memberPoints: _points);
  }
}
