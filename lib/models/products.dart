// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';

import 'firebase.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return [...(_products.where((p) => p.isFavorite)).toList()];
  }

  Future<void> addProduct(
      {required String title,
      required String description,
      required double price,
      required String imageUrl}) async {
    final response = await Firebase.postData('products.json', {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isFavorite': false,
    });

    String id =
        (json.decode(response.body) as Map<dynamic, dynamic>)['name'] as String;

    _products.add(Product(
        id: id,
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl));
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    // Storing backup and removing local copy
    int index = _products.indexOf(product);
    Product backup = _products[index];
    _products.remove(product);
    notifyListeners();

    try {
      await Firebase.deleteData('products/${product.id}.json');
    } catch (error) {
      // Roll Back Changes
      _products.insert(index, backup);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    if (_products.any((p) => p.id == product.id)) {
      await Firebase.patchData('products/${product.id}.json', {
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      });
      _products.removeWhere((p) => p.id == product.id);
      _products.add(product);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    var map;
    try {
      final response = await Firebase.getData('products.json');
      map = json.decode(response.body) as Map<String, dynamic>;
    } catch (error) {
      _products = [];
      notifyListeners();
      rethrow;
    }

    List<Product> fromServer = [];

    map.forEach((id, data) {
      fromServer.add(
        Product(
          id: id,
          title: data['title'],
          description: data["description"],
          price: data["price"],
          imageUrl: data['imageUrl'],
          isFavorite: data['isFavorite'],
        ),
      );
    });

    if (fromServer.any((p1) => !_products.any((p2) => p2.id == p1.id)) ||
        _products.any((p1) => !fromServer.any((p2) => p2.id == p1.id))) {
      _products = fromServer;
      notifyListeners();
    }
  }
}
