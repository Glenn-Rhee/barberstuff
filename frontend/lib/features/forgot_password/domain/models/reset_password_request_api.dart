class ResetPasswordRequestApi {
  final String resetToken;
  final String newPassword;

  const ResetPasswordRequestApi({required this.resetToken, required this.newPassword});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reset_token': resetToken,
      'new_password': newPassword
    };
  }
}