import 'package:flutter_shop_app/models/login_status.dart';

class LoginException implements Exception{
  final String message;
  final LoginStatus loginStatus;

  LoginException(this.message, this.loginStatus);

  @override
  String toString() {
    return message;
  }
}