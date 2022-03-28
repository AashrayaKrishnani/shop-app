import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

import '../models/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const String route = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Orders ordersData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders! 😍'),
      ),
      body: ListView.builder(
        itemBuilder: ((context, index) => OrderItem(ordersData.orders[index])),
        itemCount: ordersData.orders.length,
      ),
      drawer: const MainDrawer(),
    );
  }
}
