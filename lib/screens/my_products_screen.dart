import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_form_screen.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/my_product_item.dart';

import '../models/products.dart';

class MyProductsScreen extends StatelessWidget {
  static const String route = '/my-products';
  const MyProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Products productsData = Provider.of<Products>(context);

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
                      builder: (ctx) => AlertDialog(
                            backgroundColor: Theme.of(ctx).errorColor,
                            title: const Text(
                              'Dev Messed Up! 😅',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'You can be Nice and send us a ScreenShot of this (at loveaash3@gmail.com) so we can solve it out! 🙏',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white)),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'Ahh Alright!',
                                    style: TextStyle(color: Colors.red),
                                  ))
                            ],
                          ));
                });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) =>
            MyProductItem(productsData.products[index]),
        itemCount: productsData.products.length,
      ),
      drawer: const MainDrawer(),
    );
  }
}
