import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';

class DebugOverrides extends ChangeNotifier {
  MemberTier? _tier;
  int? _points;

  MemberTier? get tier => _tier;
  int? get points => _points;

  bool get isActive => _tier != null || _points != null;

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

  void reset() {
    if (!isActive) return;
    _tier = null;
    _points = null;
    notifyListeners();
  }

  CustomerProfile? apply(CustomerProfile? profile) {
    if (profile == null || !isActive) return profile;
    return profile.copyWith(tier: _tier, memberPoints: _points);
  }
}
