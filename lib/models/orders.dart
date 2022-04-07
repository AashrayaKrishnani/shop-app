import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';

import 'cart.dart';
import 'firebase.dart';

class OrderItemData {
  String id = '';
  final List<CartItemData> cartItemList;
  final double total;
  final DateTime time;

  OrderItemData(this.cartItemList, this.total, this.time, {this.id = ''}) {
    if (id == '') {
      id = Object.hash(cartItemList, total).toString() +
          time.hashCode.toString();
    }
  }
}

class Orders with ChangeNotifier {
  // ignore: prefer_final_fields
  List<OrderItemData> _orders = [];

  List<OrderItemData> get orders => [..._orders];

  Future<void> addOrder(List<CartItemData> cartItemList, double total) async {
    if (cartItemList.isEmpty) return;

    DateTime now = DateTime.now();

    List<Map<String, dynamic>> cartItems = [];

    for (var ci in cartItemList) {
      cartItems.add({
        'quantity': ci.quantity,
        'id': ci.id,
        'product': {
          'title': ci.product.title,
          'id': ci.product.id,
          "description": ci.product.description,
          "price": ci.product.price,
          "imageUrl": ci.product.imageUrl
        }
      });
    }

    // Adding Order to Server
    final response = await Firebase.postData('orders.json', {
      'total': total,
      'cartItemList': cartItems,
      'dateTime': now.toIso8601String(),
    });

    String id = (json.decode(response.body) as Map<String, dynamic>)['name'];

    _orders.insert(0, OrderItemData(cartItemList, total, now, id: id));
    notifyListeners();
  }

  Future<void> refresh() async {
    Map<dynamic, dynamic> map;
    try {
      final response = await Firebase.getData('orders.json');
      map = json.decode(response.body) as Map<String, dynamic>;
    } catch (error) {
      _orders = [];
      notifyListeners();
      rethrow;
    }

    List<OrderItemData> fromServer = [];

    map.forEach((id, data) {
      List<CartItemData> cartItemList = [];

      for (var ciData in (data['cartItemList'] as List<dynamic>)) {
        Product product = Product(
            id: ciData['product']['id'],
            title: ciData['product']['title'],
            description: ciData['product']['description'],
            price: ciData['product']['price'],
            imageUrl: ciData['product']['imageUrl']);
        cartItemList.add(CartItemData(product,
            quantity: ciData['quantity'], id: ciData['id']));
      }

      fromServer.add(OrderItemData(
          cartItemList, data['total'], DateTime.parse(data['dateTime']),
          id: id));
    });

    if (fromServer.any((p1) => !_orders.any((p2) => p2.id == p1.id)) ||
        _orders.any((p1) => !fromServer.any((p2) => p2.id == p1.id))) {
      _orders = fromServer;
      notifyListeners();
    }
  }
}
