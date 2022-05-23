import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/products.dart';

import '../models/auth.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../widgets/badge.dart';
import 'cart_screen.dart';

class ProductScreen extends StatelessWidget {
  static const String route = '/product';

  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Product product = Provider.of<Product>(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(product.title),
      //   actions: [
      //     Consumer<Cart>(
      //       builder: (ctx, cart, child) =>
      //           Badge(child: child, value: cart.itemCount.toString()),
      //       child: IconButton(
      //         onPressed: () =>
      //             Navigator.of(context).pushNamed(CartScreen.route),
      //         icon: const Icon(Icons.shopping_cart),
      //       ),
      //     ),
      //   ],
      // ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
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
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: product.id,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      child: Container(
                        width: 50,
                        color: Colors.black87.withOpacity(.8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          product.title,
                          softWrap: true,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(fontSize: 30, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 2),
                            child: Chip(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                label: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    'Description',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                            color: Colors.white, fontSize: 18),
                                  ),
                                )),
                          ),
                          Chip(
                            label: Text(
                              '\$${product.price}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 20),
                            ),
                          ),
                        ]),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Text(
                          product.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 800,
                    )
                  ],
                ),
              ),
            ],
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            // SizedBox(
            //   width: double.infinity,
            //   height: 300,
            //   child: Hero(
            //     tag: product.id,
            //     child: ClipRRect(
            //       borderRadius: const BorderRadius.all(Radius.circular(20)),
            //       child: Image.network(
            //         product.imageUrl,
            //         fit: BoxFit.contain,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Text(
            //   '\$${product.price}',
            //   style: const TextStyle(color: Colors.grey, fontSize: 20),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Text(
            //   product.description,
            //   style: Theme.of(context).textTheme.bodyText1,
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            //   ],
            // ),
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
                              onPressed: () async {
                                try {
                                  await product.toggleFavorite();
                                } catch (error) {
                                  ScaffoldMessenger.of(context)
                                      .clearMaterialBanners();
                                  ScaffoldMessenger.of(context)
                                      .showMaterialBanner(
                                    MaterialBanner(
                                      backgroundColor: Colors.red,
                                      content: const Text(
                                        'Error Changing Status, Rolling Back Changes.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      actions: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: TextButton(
                                            onPressed: () =>
                                                ScaffoldMessenger.of(context)
                                                    .clearMaterialBanners(),
                                            child: const Text(
                                              'Okie! 😼',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                  await Future.delayed(
                                          const Duration(seconds: 3))
                                      .then((_) => ScaffoldMessenger.of(context)
                                          .clearMaterialBanners());
                                }
                              },
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
