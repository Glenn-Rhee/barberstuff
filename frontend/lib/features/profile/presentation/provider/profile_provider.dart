import 'package:flutter/material.dart';

import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository) {
    load();
  }

  final ProfileRepository _repository;

  CustomerProfile? _profile;
  bool _isLoading = false;
  ApiException? _error;

  CustomerProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  bool get isFirstLoad => _profile == null && _isLoading;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getCustomerProfile();
      _error = null;
    } on ApiException catch (e) {
      _error = e;
    }

    _isLoading = false;
    notifyListeners();
  }
}
