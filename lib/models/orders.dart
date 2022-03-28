import 'package:flutter/material.dart';

import 'cart.dart';

class OrderItemData {
  String id = '';
  final List<CartItemData> cartItemList;
  final double total;
  final DateTime time;

  OrderItemData(this.cartItemList, this.total, this.time) {
    id = Object.hash(cartItemList, total).toString() + time.hashCode.toString();
  }
}

class Orders with ChangeNotifier {
  // ignore: prefer_final_fields
  List<OrderItemData> _orders = [];

  List<OrderItemData> get orders => [..._orders];

  void addOrder(List<CartItemData> items, double total) {
    if (items.isEmpty) return;

    _orders.insert(0, OrderItemData(items, total, DateTime.now()));
    notifyListeners();
  }
}
