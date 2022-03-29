import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_form_screen.dart';

import '../models/product.dart';
import '../models/products.dart';

class MyProductItem extends StatelessWidget {
  final Product product;

  const MyProductItem(this.product, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: product.image.image,
          ),
          title: Text(product.title),
          subtitle: Text(product.description),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(ProductFormScreen.route, arguments: product)
                        .then((value) {
                      bool result = value == null ? (false) : (value as bool);

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(
                            seconds: 2,
                          ),
                          content: Text(
                            result
                                ? 'Succesfully Edited Product.'
                                : 'Cancelled Succesfully.',
                          ),
                          backgroundColor: result ? Colors.green : Colors.red,
                        ),
                      );
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Really Want to Delete?'),
                        content: ListTile(
                          title: Text(product.title),
                          subtitle: Text('\$${product.price}'),
                          trailing: CircleAvatar(
                            backgroundImage: product.image.image,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              'Remove',
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ).then((confirmDelete) {
                      confirmDelete ??= false;
                      if (confirmDelete) {
                        Provider.of<Products>(context, listen: false)
                            .removeProduct(product);
                      }

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(
                            seconds: 2,
                          ),
                          content: Text(
                            confirmDelete
                                ? 'Succesfully Deleted.'
                                : 'Cancelled Succesfully.',
                          ),
                          backgroundColor:
                              confirmDelete ? Colors.green : Colors.red,
                        ),
                      );
                    });
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
