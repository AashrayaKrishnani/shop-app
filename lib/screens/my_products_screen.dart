import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
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