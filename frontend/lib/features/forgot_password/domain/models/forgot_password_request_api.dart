class ForgotPasswordRequestApi {
  final String email;
  
  const ForgotPasswordRequestApi({required this.email});

  Map<String, dynamic> toJson() {
    return <String,dynamic>{'email': email};
  }

  
}