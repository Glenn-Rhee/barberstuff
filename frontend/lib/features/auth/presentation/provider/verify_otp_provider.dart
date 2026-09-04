import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

class VerifyOtpProvider extends ChangeNotifier {
  VerifyOtpProvider(
    this._repository, {
    required String userId,
    required this.registerRequest,
  }) : _userId = userId {
    for (final TextEditingController c in controllers) {
      c.addListener(_onDigitChanged);
    }
  }

  static const int otpLength = 6;
  static const int resendCooldown = 180;

  final AuthRepository _repository;
  final RegisterRequestApi registerRequest;

  final List<TextEditingController> controllers = List<TextEditingController>
      .generate(otpLength, (_) => TextEditingController(), growable: false);

  final List<FocusNode> focusNodes = List<FocusNode>.generate(
    otpLength,
    (_) => FocusNode(),
    growable: false,
  );

  String _userId;
  Timer? _timer;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isComplete = false;
  bool _hasError = false;
  int _secondsLeft = 0;
  ApiException? _error;
  String? _infoMessage;

  String get userId => _userId;
  String get email => registerRequest.email;
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  bool get isComplete => _isComplete;
  bool get hasError => _hasError;
  bool get canResend => _secondsLeft == 0 && !_isResending && !_isLoading;
  int get secondsLeft => _secondsLeft;
  ApiException? get error => _error;
  String? get infoMessage => _infoMessage;

  String get otp => controllers.map((TextEditingController c) => c.text).join();

  static final RegExp _noAttemptLeft = RegExp(
    r'sisa percobaan\s*0',
    caseSensitive: false,
  );

  bool get isAttemptExhausted =>
      _error != null && _noAttemptLeft.hasMatch(_error!.rawMessage ?? '');

  void _onDigitChanged() {
    final bool next = otp.length == otpLength;
    final bool clearedError = _hasError && otp.length < otpLength;

    if (clearedError) _hasError = false;

    if (_isComplete != next || clearedError) {
      _isComplete = next;
      notifyListeners();
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsLeft = resendCooldown;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _secondsLeft--;
      if (_secondsLeft <= 0) {
        _secondsLeft = 0;
        t.cancel();
      }
      notifyListeners();
    });
  }

  void _clearOtp() {
    for (final TextEditingController c in controllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  Future<bool> submit() async {
    if (otp.length != otpLength || _isLoading) return false;

    _isLoading = true;
    _error = null;
    _infoMessage = null;
    _hasError = false;
    notifyListeners();

    try {
      await _repository.verifyOtp(
        VerifyOtpRequestApi(userId: _userId, otp: otp),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _clearOtp();
      _isLoading = false;
      _hasError = true;
      _error = e;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resend() async {
    if (!canResend) return false;

    _isResending = true;
    _error = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final RegisterResult result = await _repository.register(registerRequest);
      _userId = result.id;
      _isResending = false;
      _hasError = false;
      _clearOtp();
      _startCooldown();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isResending = false;
      _error = e;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController c in controllers) {
      c.dispose();
    }
    for (final FocusNode f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
