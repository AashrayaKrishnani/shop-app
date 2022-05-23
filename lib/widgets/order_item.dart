import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop_app/models/orders.dart';
import 'package:shop_app/widgets/badge.dart';

import '../helpers/helpers.dart';

class OrderItem extends StatefulWidget {
  const OrderItem(this.order, {Key? key}) : super(key: key);
  final OrderItemData order;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  Animation<double>? _moreDetailsFadeAnimation;
  AnimationController? _moreDetailsFadeAnimationController;

  @override
  void initState() {
    // Setting up Fade in / out animation for more details.
    _moreDetailsFadeAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _moreDetailsFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _moreDetailsFadeAnimationController!,
            curve: Curves.easeIn));

    super.initState();
  }

  Widget get moreDetails {
    return SizedBox(
      height: min(widget.order.cartItemList.length * 50 + 20, 250),
      child: ListView.builder(
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox.square(
                  dimension: 30,
                  child: Image.network(
                    widget.order.cartItemList[i].product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                widget.order.cartItemList[i].product.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  'Quantity: ${widget.order.cartItemList[i].quantity}x\nPrice: \$${widget.order.cartItemList[i].product.price}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              trailing: Chip(
                label: Text(
                  '\$${widget.order.cartItemList[i].product.price * widget.order.cartItemList[i].quantity}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        itemCount: widget.order.cartItemList.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: [
              ListTile(
                leading: Badge(
                  color: Colors.white,
                  value: widget.order.cartItemList.length.toString(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox.square(
                      dimension: 80,
                      child: Image.network(
                        widget.order.cartItemList[0].product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Total \$${formatAmt(widget.order.total)}',
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: Text(formatDateTime(widget.order.time)),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                      if (_expanded) {
                        _moreDetailsFadeAnimationController!.forward();
                      } else {
                        _moreDetailsFadeAnimationController!.reverse();
                      }
                    });
                  },
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ),
              if (_expanded) const Divider(),
              AnimatedContainer(
                constraints: BoxConstraints(maxHeight: _expanded ? 200 : 0),
                duration: const Duration(milliseconds: 300),
                child: FadeTransition(
                  opacity: _moreDetailsFadeAnimation!,
                  child: moreDetails,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
