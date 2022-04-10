// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';

import 'auth.dart';
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
    final response = await Firebase.postData('products/${Auth.id}.json', {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'creatorId': Auth.id,
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
      await Firebase.deleteData('products/${Auth.id}/${product.id}.json');
    } catch (error) {
      // Roll Back Changes
      _products.insert(index, backup);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    if (_products.any((p) => p.id == product.id)) {
      await Firebase.patchData('products/${Auth.id}/${product.id}.json', {
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

  Future<void> refresh([onlyUserProducts = false]) async {
    try {
      // Getting the Products Data.
      String verb =
          onlyUserProducts ? 'products/${Auth.id}.json' : 'products.json';

      final response = await Firebase.getData(verb);

      // Getting the Favorites Data.
      final favoritesData = await Firebase.getData('favorites/${Auth.id}.json');

      // Decoding.
      final favorites = json.decode(favoritesData.body);
      final idDataMap = onlyUserProducts
          ? {Auth.id: json.decode(response.body) as Map<String, dynamic>}
          : json.decode(response.body) as Map<String, dynamic>;

      // Updating.
      List<Product> fromServer = [];

      idDataMap.forEach((uid, userProducts) {
        if (userProducts != null) {
          (userProducts as Map<String, dynamic>).forEach((id, data) {
            bool isFavorite =
                favorites == null ? false : favorites[id] ?? false;

            fromServer.add(
              Product(
                id: id,
                title: data['title'],
                description: data["description"],
                price: data["price"],
                imageUrl: data['imageUrl'],
                isFavorite: isFavorite,
              ),
            );
          });
        }
      });

      _products = fromServer;
      notifyListeners();
    } catch (error) {
      _products = [];
      notifyListeners();
      rethrow;
    }
  }
}
