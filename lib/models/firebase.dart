import 'dart:convert';

import 'package:http/http.dart';

class Firebase {
  static const String url =
      'https://shopapp-f8ba7-default-rtdb.firebaseio.com/';

  static Future<Response> postData(String verb, Map body) async {
    final response =
        await post(Uri.parse(url + '/' + verb), body: json.encode(body));
    return response;
  }

  static Future<Response> getData(String verb) async {
    final response = await get(Uri.parse(url + '/' + verb));
    return response;
  }

  static Future<Response> patchData(String verb, Map body) async {
    final response =
        await patch(Uri.parse(url + '/' + verb), body: json.encode(body));
    print(verb);
    print(response.body + "   " + response.statusCode.toString());
    return response;
  }
}
