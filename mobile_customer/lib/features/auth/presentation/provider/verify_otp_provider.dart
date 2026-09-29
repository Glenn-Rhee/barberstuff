import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/register_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/registration.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/verify_otp_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/register_account.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/request_password_reset.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/verify_otp.dart';

enum OtpPurpose { register, forgotPassword }

class VerifyOtpProvider extends ChangeNotifier {
  VerifyOtpProvider(
    this._verifyOtp,
    this._register,
    this._requestReset, {
    required String userId,
    required this.email,
    required this.purpose,
    this.registerRequest,
  }) : _userId = userId {
    for (final TextEditingController c in controllers) {
      c.addListener(_onDigitChanged);
    }
  }

  static const int otpLength = 6;
  static const int resendCooldown = 180;

  final VerifyOtp _verifyOtp;
  final RegisterAccount _register;
  final RequestPasswordReset _requestReset;
  final Registration? registerRequest;
  final String email;
  final OtpPurpose purpose;

  final List<TextEditingController> controllers =
      List<TextEditingController>.generate(
        otpLength,
        (_) => TextEditingController(),
        growable: false,
      );

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
  String? _resetToken;

  String get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  bool get isComplete => _isComplete;
  bool get hasError => _hasError;
  bool get canResend => _secondsLeft == 0 && !_isResending && !_isLoading;
  int get secondsLeft => _secondsLeft;
  ApiException? get error => _error;
  String? get resetToken => _resetToken;

  String get otp => controllers.map((TextEditingController c) => c.text).join();

  static final RegExp _noAttemptLeft = RegExp(
    r'sisa percobaan\s*0(?!\d)',
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
    _hasError = false;
    notifyListeners();

    try {
      final VerifyOtpResult result = await _verifyOtp(
        VerifyOtpParams(userId: _userId, otp: otp),
      );
      _resetToken = result.resetToken;
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
    notifyListeners();

    try {
      if (purpose == OtpPurpose.register) {
        final RegisterResult result = await _register(registerRequest!);
        _userId = result.id;
      } else {
        final ForgotPasswordResult result = await _requestReset(email);
        _userId = result.userId;
      }

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
