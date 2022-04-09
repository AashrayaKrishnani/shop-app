import 'dart:convert';

import 'package:http/http.dart';

import 'auth.dart';
import 'http_exception.dart';

class Firebase {
  static const String url =
      'https://shopapp-f8ba7-default-rtdb.firebaseio.com/';

  static Future<Response> postData(String verb, Object body) async {
    final response = await post(Uri.parse(applyAuth(url + '/' + verb)),
        body: json.encode(body));

    if (response.statusCode >= 400) {
      throw HttpException(response.body);
    }
    return response;
  }

  static Future<Response> getData(String verb) async {
    final response = await get(Uri.parse(applyAuth(url + '/' + verb)));

    if (response.statusCode >= 400) {
      throw HttpException(response.body);
    }
    return response;
  }

  static Future<Response> patchData(String verb, Object body) async {
    final response = await patch(Uri.parse(applyAuth(url + '/' + verb)),
        body: json.encode(body));
    if (response.statusCode >= 400) {
      throw HttpException(response.body);
    }

    return response;
  }

  static Future<Response> putData(String verb, Object body) async {
    final response = await put(Uri.parse(applyAuth(url + '/' + verb)),
        body: json.encode(body));
    if (response.statusCode >= 400) {
      throw HttpException(response.body);
    }

    return response;
  }

  static Future<Response> deleteData(String verb) async {
    final response = await delete(Uri.parse(applyAuth(url + '/' + verb)));

    if (response.statusCode >= 400) {
      throw HttpException(response.body);
    }

    return response;
  }

  static String applyAuth(String url) {
    String authToken = Auth.token;

    if (authToken == '') {
      return url;
    }

    return url.contains('?')
        ? url + (url + "&auth=$authToken")
        : (url + "?auth=$authToken");
  }
}
