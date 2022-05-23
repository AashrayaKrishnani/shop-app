import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';

import 'models/auth.dart';
import 'models/cart.dart';
import 'models/orders.dart';
import 'models/products.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/my_products_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_screen.dart';
import 'screens/products_screen.dart';

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
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomRouteTransitionBuilder(),
                TargetPlatform.iOS: CustomRouteTransitionBuilder()
              },
            ),
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
