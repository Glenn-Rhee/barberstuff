class ResetPasswordRequestApi {
  const ResetPasswordRequestApi({
    required this.resetToken,
    required this.newPassword,
  });

  final String resetToken;
  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'reset_token': resetToken,
    'new_password': newPassword,
  };
}