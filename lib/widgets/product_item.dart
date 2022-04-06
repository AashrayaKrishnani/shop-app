import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_screen.dart';
import 'package:shop_app/widgets/badge.dart';

import '../helpers.dart';
import '../models/cart.dart';
import '../models/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  void favoriteButtonPressed(Product product, BuildContext context) async {
    try {
      await product.toggleFavorite();
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(
            seconds: product.isFavorite ? 1 : 2,
          ),
          content: const Text('Error Changing Status, Rolling Back Changes.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(
          seconds: product.isFavorite ? 1 : 2,
        ),
        content: Text(product.isFavorite
            ? 'Added to Favorites! ❤'
            : 'Removed From Favorites. 😥'),
        backgroundColor: product.isFavorite
            ? Theme.of(context).colorScheme.tertiary
            : Colors.black87,
        action: !product.isFavorite
            ? SnackBarAction(
                label: '❤ ADD IT BACK ❤',
                onPressed: () => favoriteButtonPressed(product, context))
            : null,
      ),
    );
  }

  void cartButtonPressed(Cart cart, Product product, BuildContext context) {
    cart.addItem(product);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(
          seconds: 1,
        ),
        content: Text(
          '\'${product.title}\' Added to Cart! 🏆',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Product product = Provider.of<Product>(context);

    return GridTile(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ChangeNotifierProvider.value(
                value: product, child: const ProductScreen())),
          ),
        ),
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.contain,
        ),
      ),
      footer: ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        child: GridTileBar(
          backgroundColor: Colors.black87,
          title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  product.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  '\$ ' + formatAmt(product.price).toString(),
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ]),
          leading: IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Theme.of(context).colorScheme.tertiary,
            onPressed: () => favoriteButtonPressed(product, context),
          ),
          trailing: Consumer<Cart>(
            builder: (ctx, cart, child) {
              final int itemCount = cart.getItemCount(product);
              return itemCount > 0
                  ? Badge(
                      color: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_rounded),
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () =>
                            cartButtonPressed(cart, product, context),
                      ),
                      value: itemCount.toString())
                  : IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () =>
                          cartButtonPressed(cart, product, context),
                    );
            },
          ),
        ),
      ),
    );
  }
}
