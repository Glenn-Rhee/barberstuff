import 'package:flutter/material.dart';

import 'package:mobile_barberstuff/core/debug/debug_overrides.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository, this._overrides) {
    _overrides.addListener(notifyListeners);
    load();
  }

  final ProfileRepository _repository;
  final DebugOverrides _overrides;

  CustomerProfile? _fetched;
  bool _isLoading = false;
  ApiException? _error;

  CustomerProfile? get fetched => _fetched;
  CustomerProfile? get profile => _overrides.apply(_fetched);

  bool get isLoading => _isLoading;
  ApiException? get error => _error;
  bool get isFirstLoad => _fetched == null && _isLoading;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fetched = await _repository.getCustomerProfile();
      _error = null;
    } on ApiException catch (e) {
      _error = e;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _overrides.removeListener(notifyListeners);
    super.dispose();
  }
}
