import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/cart_item.dart';

import '../models/cart.dart';
import '../models/orders.dart';
import '../models/products.dart';

class CartScreen extends StatelessWidget {
  static const String route = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Cart cart = Provider.of<Cart>(context);
    Products productsData = Provider.of<Products>(context);
    cart.update(productsData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bag of Goodness!'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.netPrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    onPressed: cart.netPrice != 0
                        ? () {
                            Provider.of<Orders>(context, listen: false)
                                .addOrder(cart.items, cart.netPrice);
                            cart.clear();
                          }
                        : null,
                    child: Text(
                      'Order Now',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: ((context, index) =>
                  CartItem(cartItemData: cart.items[index])),
              itemCount: cart.itemCount,
            ),
          )
        ],
      ),
    );
  }
}
