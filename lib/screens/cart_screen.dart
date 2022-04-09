import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/products_screen.dart';
import 'package:shop_app/widgets/cart_item.dart';

import '../models/cart.dart';
import '../models/orders.dart';
import '../models/products.dart';
import '../widgets/error_dialog.dart';

class CartScreen extends StatefulWidget {
  static const String route = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isWaiting = false;

  final errorDialog = const ErrorDialog(
    title: 'Error Placing Order 🙏',
    content: 'Probably an Internet issue, I messed up coding maybe ;p',
    buttonMessage: 'It\'s Okay, Chill out! 😼',
  );

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bag of Goodness!'),
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) {
          Future.delayed(Duration.zero)
              .then((value) => cart.update(productsData));
          return Column(
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
                        onPressed: cart.netPrice != 0 || isWaiting
                            ? () async {
                                setState(() {
                                  isWaiting = true;
                                });
                                final sms = ScaffoldMessenger.of(context);

                                try {
                                  await Provider.of<Orders>(context,
                                          listen: false)
                                      .addOrder(cart.items, cart.netPrice);
                                  cart.clear();

                                  setState(() {
                                    isWaiting = false;
                                  });
                                  sms.clearMaterialBanners();
                                  sms.showMaterialBanner(
                                    MaterialBanner(
                                      backgroundColor: Colors.green,
                                      content: const Text(
                                        'Succesfully Placed Order. View in My Order 🥳',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      actions: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: TextButton(
                                            onPressed: () {
                                              sms.clearMaterialBanners();
                                              final nav = Navigator.of(context);
                                              nav.popUntil((route) =>
                                                  route.settings.name ==
                                                  ProductsScreen.route);
                                              nav.pushNamed(OrdersScreen.route);
                                            },
                                            child: Text(
                                              'Okie! 😼',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                  Future.delayed(const Duration(seconds: 5))
                                      .then((value) =>
                                          sms.clearMaterialBanners());
                                } catch (error) {
                                  setState(() {
                                    isWaiting = false;
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => errorDialog);
                                  });
                                }
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
              isWaiting
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height / 4,
                        0,
                        0,
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemBuilder: ((context, index) =>
                            CartItem(cartItemData: cart.items[index])),
                        itemCount: cart.itemCount,
                      ),
                    )
            ],
          );
        },
      ),
    );
  }
}
