import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/products.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../widgets/badge.dart';
import 'cart_screen.dart';

class ProductScreen extends StatelessWidget {
  static const String route = '/product';

  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Product product = ModalRoute.of(context)?.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          Consumer<Cart>(
            builder: (ctx, cart, child) =>
                Badge(child: child, value: cart.itemCount.toString()),
            child: IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.route),
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image(
                    image: product.image.image,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(color: Colors.grey, fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Positioned(
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 200,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: Container(
                        height: 60,
                        color: Colors.pink.shade400,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Consumer<Products>(
                            builder: (context, productData, child) =>
                                IconButton(
                              onPressed: () =>
                                  productData.toggleFavorite(product),
                              icon: Icon(
                                product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: Container(
                        height: 60,
                        color: Theme.of(context).colorScheme.secondary,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Consumer<Cart>(
                            builder: (ctx, cart, child) {
                              final int itemCount = cart.getItemCount(product);
                              return itemCount > 0
                                  ? Badge(
                                      color: Colors.white,
                                      child: IconButton(
                                        iconSize: 30,
                                        icon: const Icon(
                                            Icons.shopping_cart_rounded),
                                        color: Colors.white,
                                        onPressed: () => cart.addItem(product),
                                      ),
                                      value: itemCount.toString())
                                  : IconButton(
                                      iconSize: 30,
                                      icon: const Icon(
                                          Icons.shopping_cart_outlined),
                                      color: Colors.white,
                                      onPressed: () => cart.addItem(product),
                                    );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
