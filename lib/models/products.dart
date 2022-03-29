// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      image: Image.asset('assets/images/Red Shirt.jpg'),
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      image: Image.asset('assets/images/Trousers.jpg'),
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      image: Image.asset('assets/images/Yellow Scarf.jpg'),
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      image: Image.asset('assets/images/A Pan.jpg'),
    ),
  ];

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return [...(_products.where((p) => p.isFavorite)).toList()];
  }

  void addProduct(Product product) {
    _products.add(product);
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
