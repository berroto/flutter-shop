import 'dart:async';
import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shop_app/models/login_exception.dart';
import 'package:flutter_shop_app/models/login_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/const.dart' as Constant;

class Auth with ChangeNotifier {
  late CognitoUserPool _userPool;
  late DateTime _expiryDate;
  late String? _token;
  Timer? _logoutTimer;

  String? get token {
    if ( _token == null) {
      return null;
    }
    return _token!;
  }

  String? get isAuth{
    if ( _token == null)
      return null;
    var s = _token!;
    if (_expiryDate.isAfter(DateTime.now()) && s.isNotEmpty) {
      return _token;
    }
    return null;
  }

  Auth() {
    this._userPool = CognitoUserPool(
      Constant.CognitoUserPoolId,
      Constant.CognitoClientId
    );
    _expiryDate = DateTime.now().subtract(Duration(days: 10));
    _token = null;
  }

  Future<void> signUp(String email, String password ) async {
    try {
      final userAttributes = [
        AttributeArg(name: 'email', value: email)
      ];
      var data = await this._userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );
      print(data);
    } catch (e) {
      print(e);
      throw e;
    }
  }
  Future<void> login(String email, String password ) async {
    final cognitoUser = CognitoUser(email, this._userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );
    CognitoUserSession? session;
    try {
      session = await cognitoUser.authenticateUser(authDetails);
      if ( session == null){
        throw LoginException("Username / Password wrong", LoginStatus.LoginError);
      }
      await getUserAttributes(session);
    } on CognitoUserNewPasswordRequiredException catch (e) {
      // handle New Password challenge
      throw LoginException(e.message!, LoginStatus.NewPasswordRequired);
    } on CognitoUserMfaRequiredException catch (e) {
      // handle SMS_MFA challenge
      throw LoginException(e.message!, LoginStatus.MFARequired);
    } on CognitoUserSelectMfaTypeException catch (e) {
      // handle SELECT_MFA_TYPE challenge
      throw LoginException(e.message!, LoginStatus.SelectMFA);
    } on CognitoUserMfaSetupException catch (e) {
      // handle MFA_SETUP challenge
      throw LoginException(e.message!, LoginStatus.MFASetup);
    } on CognitoUserTotpRequiredException catch (e) {
      // handle SOFTWARE_TOKEN_MFA challenge
      throw LoginException(e.message!, LoginStatus.UserTotpRequired);
    } on CognitoUserCustomChallengeException catch (e) {
      // handle CUSTOM_CHALLENGE challenge
      throw LoginException(e.message!, LoginStatus.CustomChallengeRequired);
    } on CognitoUserConfirmationNecessaryException catch (e) {
      // handle User Confirmation Necessary
      throw LoginException(e.message!, LoginStatus.ConfirmationRequired);
    } on CognitoClientException catch (e) {
      // handle Wrong Username and Password and Cognito Client
      throw LoginException(e.message!, LoginStatus.ClientException);
    }catch (e) {
      print(e);
      throw LoginException(e.toString(), LoginStatus.Unknown);

    }
    final CognitoUserSession finalSession = session!;
    this._token = finalSession.getAccessToken().getJwtToken();
    this._expiryDate = DateTime.fromMillisecondsSinceEpoch(finalSession.getAccessToken().getExpiration() * 1000);
    //this._expiryDate = DateTime.now().add(Duration(seconds: finalSession.getAccessToken().getExpiration()));
    print(session?.getAccessToken().getJwtToken());
    _autoLogout();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", _token!);
    prefs.setInt("expiry", _expiryDate.millisecondsSinceEpoch);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("token")) {
      _token = prefs.getString("token");
    }
    if (prefs.containsKey("expiry")) {
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(prefs.getInt("expiry")!);
    }
    if (_expiryDate.isAfter(DateTime.now())) {
      notifyListeners();
      _autoLogout();
      return true;
    }
    return false;
  }

  void logout () async{
    this._expiryDate = DateTime(1970);
    this._token = "";
    if ( _logoutTimer != null){
      _logoutTimer?.cancel();
      _logoutTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  Future<void> getUserAttributes(CognitoUserSession? session) async {
    final CognitoUser user = CognitoUser(null, this._userPool, signInUserSession: session);

    // NOTE: in order to get the email from the list of user attributes, make sure you select email in the list of
    // attributes in Cognito and map it to the email field in the identity provider.
    final attributes = await user.getUserAttributes();
    for (CognitoUserAttribute attribute in attributes!) {
      if (attribute.getName() == "email") {
        user.username = attribute.getValue();
        break;
      }

    }
  }

  void _autoLogout(){
    if ( _logoutTimer != null){
      _logoutTimer?.cancel();
    }
    int timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}