import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/products.dart';

enum ProductFormType {
  edit,
  add,
}

class ProductFormScreen extends StatefulWidget {
  static const String route = '/product-form';

  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  bool init = true;

  ProductFormType _type = ProductFormType.add;

  final _form = GlobalKey<FormState>();

  Product? _product;

  String _title = '';
  String _description = '';
  double _price = 0;
  Image? _image;

  final _titleField = GlobalKey<FormFieldState>();
  final _priceField = GlobalKey<FormFieldState>();
  final _descriptionField = GlobalKey<FormFieldState>();
  final _imageField = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
  }

  void _submitForm() {
    bool isValid = _form.currentState!.validate();

    if (isValid) {
      _form.currentState?.save();
      if (_type == ProductFormType.add) {
        Provider.of<Products>(context, listen: false).addProduct(
            description: _description,
            image: _image!,
            price: _price,
            title: _title);
      } else {
        Provider.of<Products>(context, listen: false).updateProduct(Product(
            id: _product!.id,
            description: _description,
            image: _image!,
            price: _price,
            title: _title));
      }
      Navigator.of(context).pop(true);
    }
  }

  Widget get _imagePreview {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        width: 100,
        child: Image(image: _image!.image, fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (init) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _product = ModalRoute.of(context)?.settings.arguments as Product;
        _type = ProductFormType.edit;
      }
      if (_type == ProductFormType.edit) _image = _product!.image;
      init = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_type == ProductFormType.edit
            ? 'Edit ${_product?.title}'
            : 'Add New Product.'),
      ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: TextFormField(
                    key: _titleField,
                    initialValue:
                        _type == ProductFormType.edit ? _product?.title : '',
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    autofocus: _type == ProductFormType.edit ? false : true,
                    keyboardType: TextInputType.name,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        _titleField.currentState?.validate(),
                    validator: (val) {
                      if (val == null ||
                          val.isEmpty ||
                          val.toString().trim().isEmpty) {
                        return 'Please provide a product title.';
                      }
                      return null;
                    },
                    onSaved: (val) => setState(() {
                      _title = val ?? '';
                    }),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: TextFormField(
                    key: _priceField,
                    initialValue: _type == ProductFormType.edit
                        ? _product?.price.toString()
                        : '',
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                    keyboardType: TextInputType.number,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        _priceField.currentState?.validate(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please provide a price.';
                      }

                      if (double.tryParse(val) == null) {
                        return 'Please Enter a Valid Price';
                      }

                      if (double.tryParse(val)! <= 0) {
                        return 'Sweet little Price, Please Be Positive! ';
                      }

                      return null;
                    },
                    onSaved: (val) => setState(() {
                      _price = double.tryParse(val!) ?? 0;
                    }),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: TextFormField(
                    key: _descriptionField,
                    initialValue: _type == ProductFormType.edit
                        ? _product?.description
                        : '',
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                    keyboardType: TextInputType.multiline,
                    enableSuggestions: false,
                    validator: (val) {
                      if (val == null || val.toString().trim().isEmpty) {
                        return 'Please provide a Description.';
                      } else if (val.toString().trim().length < 30) {
                        return 'Please make it a little longer.';
                      }

                      return null;
                    },
                    onSaved: (val) => setState(
                      () {
                        _description = val ?? '';
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: _imageField,
                          initialValue: '',
                          maxLines: 3,
                          decoration:
                              const InputDecoration(labelText: 'Image Url'),
                          keyboardType: TextInputType.url,
                          enableSuggestions: false,
                          validator: (val) {
                            if (val == null || val.toString().trim().isEmpty) {
                              return 'Please provide an Image Url.';
                            }

                            if (!(val.startsWith('http') ||
                                val.startsWith('https'))) {
                              return 'Please enter a valid Image Url';
                            }

                            return null;
                          },
                          onChanged: (val) {
                            bool isValid =
                                _imageField.currentState?.validate() ?? false;
                            if (isValid) {
                              setState(() {
                                _image = Image.network(val);
                              });
                            } else {
                              setState(() {
                                _image = null;
                              });
                            }
                          },
                          onSaved: (val) => setState(
                            () {
                              _image = val == null ? null : Image.network(val);
                            },
                          ),
                        ),
                      ),
                      if (_image != null) _imagePreview,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        iconSize: 40,
                        onPressed: () => _submitForm(),
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        iconSize: 40,
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
