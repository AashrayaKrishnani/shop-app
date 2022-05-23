import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/error_dialog.dart';
import 'package:shop_app/widgets/loading_spinner.dart';
import 'package:shop_app/widgets/sweat_smile_image.dart';

import '../models/auth.dart';
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
  final errorDialog = const ErrorDialog(
    title: 'Error Loading Products 😅',
    content:
        'Probably an Internet issue, or Maybe... there are No Products! (Hint: Add Some then! 🤭)',
    buttonMessage: 'Alrighty bud! 😼',
  );

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
      showDialog(context: context, builder: (ctx) => errorDialog);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsObject = Provider.of<Products>(context);

    // Bug: Shows all products when favorites are to be shown but favorites are actually empty.
    // if (products.isEmpty) {
    //   products = productsObject.products;
    // }

    // Checking if Authenticated.
    if (!Provider.of<Auth>(context).isIn) {
      final nav = Navigator.of(context);
      nav.popUntil((route) => !nav.canPop());
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
          ? const LoadingSpinner(
              message: 'Loading Products! 😼',
            )
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
                  setState(() {
                    products.clear();
                  });
                  showDialog(context: context, builder: (ctx) => errorDialog);
                });
              },
              child: products.isEmpty
                  ? const SweatSmileImage()
                  : GridView.builder(
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
