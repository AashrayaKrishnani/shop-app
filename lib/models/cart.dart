import 'package:flutter/material.dart';

import 'product.dart';

class CartItemData {
  final Product product;
  int quantity;
  String id = '';

  CartItemData(this.product, {this.quantity = 1}) {
    id = product.id.toString() + quantity.hashCode.toString();
  }
}

class Cart with ChangeNotifier {
  // ignore: prefer_final_fields
  List<CartItemData> _items = [];

  List<CartItemData> get items => [..._items];

  int get itemCount {
    return _items.length;
  }

  double get netPrice {
    double netPrice = 0;
    for (var item in _items) {
      netPrice += item.quantity * item.product.price;
    }
    return netPrice;
  }

  bool addItem(Product product, {int quantity = 1}) {
    int index = _items.indexWhere((item) => item.product == product);

    if (index == -1) {
      _items.add(CartItemData(product));
    } else {
      _items[index].quantity += 1;
    }
    notifyListeners();
    return true;
  }

  int getItemCount(Product product) {
    CartItemData cartItem = _items.firstWhere((ci) => ci.product == product,
        orElse: (() => CartItemData(product, quantity: 0)));

    return cartItem.quantity;
  }

  bool removeItem(CartItemData item, {int quantity = -1}) {
    bool result = true;

    if (quantity == -1) {
      bool result = _items.remove(item);
    } else {
      CartItemData data = _items[_items.indexOf(item)];
      data.quantity -= 1;
      if (data.quantity == 0) {
        result = _items.remove(data);
      }
    }
    notifyListeners();
    return result;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
