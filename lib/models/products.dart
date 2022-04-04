// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

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

  void addProduct(
      {required String title,
      required String description,
      required double price,
      required String imageUrl}) {
    _products.add(Product(
        id: Object.hashAll([title, price, imageUrl, description]).toString(),
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

  void updateProduct(Product product) {
    if (_products.any((p) => p.id == product.id)) {
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
