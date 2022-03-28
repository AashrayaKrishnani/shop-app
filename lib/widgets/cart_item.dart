import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/cart.dart';

class CartItem extends StatelessWidget {
  const CartItem({Key? key, required this.cartItemData}) : super(key: key);

  final CartItemData cartItemData;

  @override
  Widget build(BuildContext context) {
    final Cart cart = Provider.of<Cart>(context, listen: false);

    return Dismissible(
      onDismissed: (direction) => cart.removeItem(cartItemData),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Theme.of(context).errorColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                '😭',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ],
          ),
        ),
      ),
      key: ValueKey(cartItemData.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox.square(
                dimension: 80,
                child: Image.asset(
                  cartItemData.product.imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              cartItemData.product.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Quantity: ${cartItemData.quantity}x\nPrice: \$${cartItemData.product.price}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
            trailing: SizedBox(
              width: 80,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Chip(
                  label: Text(
                    '\$${cartItemData.product.price * cartItemData.quantity}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 15,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            cart.addItem(cartItemData.product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(
                                  seconds: 2,
                                ),
                                content: Text(
                                  'Yay! +1 \'${cartItemData.product.title}\' ❤',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text(
                            '😊⬆',
                            style: TextStyle(fontSize: 15, color: Colors.green),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: () {
                              cart.removeItem(cartItemData, quantity: 1);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(
                                    seconds: 2,
                                  ),
                                  content: Text(
                                    cartItemData.quantity != 0
                                        ? '-1 \'${cartItemData.product.title}\' 😥'
                                        : 'Removed ${cartItemData.product.title} ☹',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  backgroundColor: cartItemData.quantity != 0
                                      ? Colors.red
                                      : Colors.black54,
                                ),
                              );
                            },
                            child: const Text('⬇☹',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.red))),
                      ]),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
