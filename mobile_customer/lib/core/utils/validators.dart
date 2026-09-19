import 'package:mobile_barberstuff/l10n/app_localization.dart';

class Validators {
  const Validators(this._l10n);

  final AppLocalizations _l10n;

  static const int passwordMinLength = 5;
  static const int phoneMinLength = 9;
  static const int phoneMaxLength = 15;

  static final RegExp _emailPattern = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
  );
  static final RegExp _digitsPattern = RegExp(r'^[0-9]+$');

  String? required(String? value, {required String label}) {
    if (value == null || value.trim().isEmpty) {
      return _l10n.validatorRequired(label);
    }
    return null;
  }

  String? email(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return _l10n.validatorRequired(_l10n.registerEmailLabel);
    if (!_emailPattern.hasMatch(v)) return _l10n.validatorEmailInvalid;
    return null;
  }

  String? password(String? value) {
    final String v = value ?? '';
    if (v.trim().isEmpty) {
      return _l10n.validatorRequired(_l10n.registerPasswordLabel);
    }
    if (v.length < passwordMinLength) {
      return _l10n.validatorPasswordMin(passwordMinLength);
    }
    return null;
  }

  String? phoneNumber(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return _l10n.validatorRequired(_l10n.registerPhoneLabel);
    if (v.length < phoneMinLength) {
      return _l10n.validatorPhoneMin(phoneMinLength);
    }
    if (v.length > phoneMaxLength) {
      return _l10n.validatorPhoneMax(phoneMaxLength);
    }
    if (!_digitsPattern.hasMatch(v)) return _l10n.validatorPhoneDigits;
    return null;
  }
}
