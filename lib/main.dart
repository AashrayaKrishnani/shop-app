import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/cart.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_screen.dart';
import 'package:shop_app/screens/products_screen.dart';

import 'models/orders.dart';
import 'models/products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => Products()),
        ChangeNotifierProvider(create: (BuildContext context) => Cart()),
        ChangeNotifierProvider(create: ((context) => Orders())),
      ],
      child: MaterialApp(
        title: 'Shop App',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              secondary: Colors.amber,
              tertiary: Colors.pinkAccent),
          fontFamily: 'Lato',
        ),
        home: const ProductsScreen(),
        routes: {
          ProductsScreen.route: (context) => const ProductsScreen(),
          ProductScreen.route: (context) => const ProductScreen(),
          CartScreen.route: (context) => const CartScreen(),
          OrdersScreen.route: (context) => const OrdersScreen(),
        },
      ),
    );
  }
}
