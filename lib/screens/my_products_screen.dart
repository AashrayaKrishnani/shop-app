// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_form_screen.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/my_product_item.dart';

import '../models/auth.dart';
import '../models/product.dart';
import '../models/products.dart';
import '../widgets/error_dialog.dart';
import '../widgets/sweat_smile_image.dart';

class MyProductsScreen extends StatefulWidget {
  static const String route = '/my-products';
  const MyProductsScreen({Key? key}) : super(key: key);

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> myProducts = [];
  bool isLoading = false;

  final errorDialog = const ErrorDialog(
    title: 'Error Loading Products 😅',
    content:
        'Probably an Internet issue, or Maybe... You haven\'t added any Products Yet! (Hint: Add Some then! 🤭)',
    buttonMessage: 'Alrighty bud! 😼',
  );

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Products>(context, listen: false).refresh(true);
    }).catchError((error) {
      showDialog(context: context, builder: (ctx) => errorDialog);
    }).then((value) => setState(() {
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final Products productsData = Provider.of<Products>(context);
    myProducts = productsData.products;

    // Checking if Authenticated.
    if (!Provider.of<Auth>(context).isIn) {
      final nav = Navigator.of(context);
      nav.popUntil((route) => !nav.canPop());
      nav.pushReplacementNamed('/');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products! 😇'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(ProductFormScreen.route)
                    .then((value) {
                  bool result = value == null ? false : (value as bool);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(
                        seconds: 2,
                      ),
                      content: Text(
                        result
                            ? 'Succesfully Added Product.'
                            : 'Cancelled Succesfully.',
                      ),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (ctx) => const ErrorDialog(),
                  );
                });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await productsData.refresh(true).catchError(
                      (_) => showDialog(
                        context: context,
                        builder: (ctx) => errorDialog,
                      ),
                    );
                setState(() {
                  myProducts =
                      Provider.of<Products>(context, listen: false).products;
                });
              },
              child: myProducts.isEmpty
                  ? const SweatSmileImage()
                  : ListView.builder(
                      itemBuilder: (ctx, index) =>
                          MyProductItem(myProducts[index]),
                      itemCount: myProducts.length,
                    ),
            ),
      drawer: const MainDrawer(),
    );
  }
}
