import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/screens/auth_screen.dart';

class Auth with ChangeNotifier {
  String? _email;
  String? _password;
  DateTime? _expiry; // Firebase Tokens expire in an hour by default.
  String? _token;

  bool get isIn {
    if (token != '') {
      return true;
    }

    return false;
  }

  String get token {
    if (_token != null && DateTime.now().isBefore(_expiry!)) {
      return _token!;
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

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      _email = responseData['email'];
      _password = data['password'] as String;
      _token = responseData['idToken'];
      _expiry = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();

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
}
