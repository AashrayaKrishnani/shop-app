import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_form_screen.dart';

import '../models/product.dart';
import '../models/products.dart';

class MyProductItem extends StatefulWidget {
  final Product product;

  const MyProductItem(this.product, {Key? key}) : super(key: key);

  @override
  State<MyProductItem> createState() => _MyProductItemState();
}

class _MyProductItemState extends State<MyProductItem> {
  @override
  Widget build(BuildContext context) {
    final sms = ScaffoldMessenger.of(context);

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.product.imageUrl),
          ),
          title: Text(widget.product.title),
          subtitle: Text(widget.product.description),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(ProductFormScreen.route,
                            arguments: widget.product)
                        .then((value) {
                      bool result = value == null ? (false) : (value as bool);

                      sms.hideCurrentSnackBar();
                      sms.showSnackBar(
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
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Really Want to Delete?'),
                        content: ListTile(
                          title: Text(widget.product.title),
                          subtitle: Text('\$${widget.product.price}'),
                          trailing: CircleAvatar(
                            backgroundImage: FadeInImage(
                              placeholder: const AssetImage(
                                  'assets/images/product-placeholder.png'),
                              image: NetworkImage(widget.product.imageUrl),
                            ).image,
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
                    ).then(
                      (confirmDelete) async {
                        confirmDelete ??= false;

                        sms.hideCurrentSnackBar();

                        if (confirmDelete) {
                          await Provider.of<Products>(context, listen: false)
                              .removeProduct(widget.product)
                              .then((_) {
                            sms.showSnackBar(
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
                          }).catchError(
                            (error) async {
                              sms.showSnackBar(
                                const SnackBar(
                                  duration: Duration(
                                    seconds: 2,
                                  ),
                                  content: Text(
                                    'Error: Unable to Delete. 🤯',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
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
