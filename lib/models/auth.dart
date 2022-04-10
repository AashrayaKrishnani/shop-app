import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth_screen.dart';
import 'http_exception.dart';

class Auth with ChangeNotifier {
  String? _email;
  String? _password;
  static String? _id;
  static DateTime? _expiry; // Firebase Tokens expire in an hour by default.
  static String? _token;
  bool _loggedOutByError = false;
  Timer? _logInTimer;

  bool get loggedOutByError {
    if (_loggedOutByError) {
      _loggedOutByError = false;
      return true;
    }
    return _loggedOutByError;
  }

  bool get isIn {
    if (token != '') {
      return true;
    }

    return false;
  }

  static String get token {
    if (_token != null && DateTime.now().isBefore(_expiry!)) {
      return _token!;
    }
    return '';
  }

  static String get id {
    if (token != '') {
      return _id!;
    }
    return '';
  }

  Future<dynamic> auth(AuthMode authMode, Map<Object, Object> data) async {
    // Default is Login.
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAeh-EWIqfK0g4iZvzJR_8Kn_On4driKE0 ';

    if (authMode == AuthMode.signup) {
      url = url.replaceFirst('signInWithPassword', 'signUp');
    }

    if (!data.containsKey('returnSecureToken')) {
      data = {
        'returnSecureToken': true,
      }..addAll(data);
    }

    try {
      print('waiting for response');
      final response = await post(
        Uri.parse(url),
        body: json.encode(data),
      );
      print('server responded');
      // Error Checking
      if (response.statusCode >= 400) {
        try {
          throw HttpException(json.decode(response.body)['error']);
        } catch (_) {
          throw HttpException(response.body);
        }
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      print('got response');
      _email = responseData['email'];
      _password = data['password'] as String;
      _token = responseData['idToken'];
      _id = responseData['localId'];
      _expiry = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      print('LoginSuccessful notifying now');
      notifyListeners();

      // Setting up timer to auto refresh token.
      _logInTimer = Timer(
          Duration(seconds: _expiry!.difference(DateTime.now()).inSeconds),
          () async {
        await auth(authMode, data).catchError((error) {
          _loggedOutByError = true;
          logout();
        });
      });

      return response;
    } catch (e1) {
      rethrow;
    }
  }

  Future<dynamic> postData(String verb, Map<dynamic, dynamic> data) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:${verb}?key=AIzaSyAeh-EWIqfK0g4iZvzJR_8Kn_On4driKE0 ';

    try {
      final response = await post(
        Uri.parse(url),
        body: json.encode(data),
      );

      // Error Checking
      if (response.statusCode >= 400) {
        try {
          throw HttpException(json.decode(response.body)['error']);
        } catch (_) {
          throw HttpException(response.body);
        }
      }

      return response;
    } catch (error) {
      rethrow;
    }
  }

  void logout() {
    _email = null;
    _password = null;
    _expiry = null;
    _token = null;
    _id = null;
    _logInTimer?.cancel();
    _logInTimer = null;

    // Clearing out Stored Data.
    clearPrefs();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final data = await getPrefs();

    if (data != null) {
      print('Trying autologin.');
      await auth(AuthMode.login, data);
      print('AutoLogin Successful');
      return true;
    }

    return false;
  }

  Future<void> storePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    print('Got The Instance');
    final data = json.encode({'email': _email, 'password': _password});
    await prefs.setString('userData', data);
    print('prefs stored successfully');
  }

  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Cleared prefernces');
  }

  Future<dynamic> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final data = json.decode(prefs.getString('userData') as String);
      print('Got Data.');
      print(data);
      return data;
    } else {
      return null;
    }
  }
}
