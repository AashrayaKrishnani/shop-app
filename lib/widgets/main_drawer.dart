import 'package:flutter/material.dart';
import 'package:shop_app/screens/my_products_screen.dart';
import 'package:shop_app/screens/products_screen.dart';

import '../screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget buildListTile(
      BuildContext context, IconData icon, String text, Function handler) {
    return GestureDetector(
      onTap: () => handler(),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        title: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .headline6
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
                height: 90,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Teleport 🪄',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            buildListTile(
                context,
                Icons.shopping_bag_rounded,
                '⭐ Products ⭐',
                () => Navigator.of(context)
                    .pushReplacementNamed(ProductsScreen.route)),
            const Divider(),
            buildListTile(
                context,
                Icons.delivery_dining,
                '❤ My Orders ❤',
                () => Navigator.of(context)
                    .pushReplacementNamed(OrdersScreen.route)),
            const Divider(),
            buildListTile(
                context,
                Icons.edit,
                '☀ My Products ☀',
                () => Navigator.of(context)
                    .pushReplacementNamed(MyProductsScreen.route))
          ],
        ),
      ),
    );
  }
}
