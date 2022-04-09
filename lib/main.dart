import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/auth.dart';
import 'package:shop_app/models/cart.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/my_products_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_form_screen.dart';
import 'package:shop_app/screens/product_screen.dart';
import 'package:shop_app/screens/products_screen.dart';

import 'models/firebase.dart';
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
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => Products()),
        ChangeNotifierProvider(create: (BuildContext context) => Cart()),
        ChangeNotifierProvider(create: ((context) => Orders())),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          title: 'Shop App',
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
                primary: Colors.indigo,
                secondary: Colors.amber,
                tertiary: Colors.pinkAccent),
            fontFamily: 'Lato',
          ),
          home: auth.isIn ? const ProductsScreen() : const AuthScreen(),
          routes: {
            ProductsScreen.route: (ctx) => const ProductsScreen(),
            ProductScreen.route: (ctx) => const ProductScreen(),
            CartScreen.route: (ctx) => const CartScreen(),
            OrdersScreen.route: (ctx) => const OrdersScreen(),
            MyProductsScreen.route: (ctx) => const MyProductsScreen(),
            ProductFormScreen.route: (ctx) => const ProductFormScreen(),
          },
        ),
      ),
    );
  }
}
