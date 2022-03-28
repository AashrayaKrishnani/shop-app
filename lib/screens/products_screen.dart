import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../models/products.dart';
import '../widgets/main_drawer.dart';
import '../widgets/product_item.dart';

enum FilterOptions { all, favorites }

class ProductsScreen extends StatefulWidget {
  static const String route = '/products';
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product>? products;

  @override
  Widget build(BuildContext context) {
    final productsObject = Provider.of<Products>(context);
    products ??= productsObject.products;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (selected) {
                setState(() {
                  products = selected == FilterOptions.all
                      ? productsObject.products
                      : productsObject.favoriteProducts;
                });
              },
              itemBuilder: (ctx) => const [
                    PopupMenuItem(
                        child: Text('Favorites'),
                        value: FilterOptions.favorites),
                    PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOptions.all,
                    ),
                  ]),
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
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
            value: products?[index], child: const ProductItem()),
        itemCount: products?.length,
      ),
      drawer: const MainDrawer(),
    );
  }
}
