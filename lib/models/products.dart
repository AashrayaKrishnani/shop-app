// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';

import 'firebase.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: 'p1',
      title: 'The Whole Earth',
      description: 'A blue colored planet with lights, humans and some life.',
      price: .99,
      imageUrl: 'https://www.edx.org/images/brand/globe-dark-lg.png',
    ),
  ];

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

  void removeProduct(Product product) {
    _products.remove(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (_products.any((p) => p.id == product.id)) {
      await Firebase.patchData('products/${product.id}.json', {
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      });
      _products.removeWhere((p) => p.id == product.id);
      _products.add(product);
      notifyListeners();
    }
  }

  void toggleFavorite(Product product) {
    _products.firstWhere((p) => p.id == product.id).toggleFavorite();
    notifyListeners();
  }
}
