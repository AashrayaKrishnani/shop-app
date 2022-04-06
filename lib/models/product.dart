import 'package:flutter/material.dart';

import 'firebase.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavorite() async {
    // Storing old status, changing current one.
    bool oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    // Try To Update Web and Roll back if there are issues.
    try {
      await Firebase.patchData('products/$id.json', {'isFavorite': !oldStatus});
    } catch (error) {
      // Rolling back changes
      isFavorite = oldStatus;
      notifyListeners();
      throw Exception('Error Updating Favorite status to server.');
    }
  }
}
