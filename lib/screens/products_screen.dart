import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/error_dialog.dart';
import 'package:shop_app/widgets/sweat_smile_image.dart';

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
  List<Product> products = [];
  FilterOptions filterOption = FilterOptions.all;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Products>(context, listen: false).refresh();
      setState(() {
        products = Provider.of<Products>(context, listen: false).products;
        isLoading = false;
      });
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (ctx) => const ErrorDialog(
                title: 'Error Loading Products 😅',
                buttonMessage: 'Alrighty bud! 😼',
              ));
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsObject = Provider.of<Products>(context);
    if (products.isEmpty) {
      products = productsObject.products;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop 🛒'),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (selected) {
                setState(() {
                  filterOption = selected as FilterOptions;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const SweatSmileImage()
              : RefreshIndicator(
                  onRefresh: () async {
                    await productsObject.refresh().then((_) {
                      setState(() {
                        if (filterOption == FilterOptions.favorites) {
                          products = productsObject.favoriteProducts;
                        } else {
                          products = productsObject.products;
                        }
                      });
                    }).catchError((error) {
                      showDialog(
                          context: context,
                          builder: (ctx) => const ErrorDialog());
                    });
                  },
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                        value: products[index], child: const ProductItem()),
                    itemCount: products.length,
                  ),
                ),
      drawer: const MainDrawer(),
    );
  }
}
