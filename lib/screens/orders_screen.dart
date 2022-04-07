import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/error_dialog.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';
import 'package:shop_app/widgets/sweat_smile_image.dart';

import '../models/orders.dart';

class OrdersScreen extends StatefulWidget {
  static const String route = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderItemData> orders = [];
  bool isLoading = false;
  final errorDialog = const ErrorDialog(
    title: 'Error Loading Orders 😅',
    content:
        'Maybe Internet Issue or... There are no orders! (Hint: Add some! 🤭)',
    buttonMessage: 'Gotcha! 😼',
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).refresh().catchError(
            (_) => showDialog(
              context: context,
              builder: (ctx) => errorDialog,
            ),
          );
      setState(() {
        orders = Provider.of<Orders>(context, listen: false).orders;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orders ordersData = Provider.of<Orders>(context);
    orders = ordersData.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders! 😍'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ordersData.refresh().catchError(
                (_) => showDialog(
                  context: context,
                  builder: (ctx) => errorDialog,
                ),
              );
          setState(() {
            orders = Provider.of<Orders>(context, listen: false).orders;
          });
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const SweatSmileImage()
                : ListView.builder(
                    itemBuilder: ((ctx, index) => OrderItem(orders[index])),
                    itemCount: orders.length,
                  ),
      ),
      drawer: const MainDrawer(),
    );
  }
}
// FutureBuilder(
//           future: Provider.of<Orders>(context, listen: false).refresh(),
//           builder: (ctx, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done &&
//                 snapshot.error == null) {
//               return ListView.builder(
//                 itemBuilder: ((ctx, index) =>
//                     OrderItem(ordersData.orders[index])),
//                 itemCount: ordersData.orders.length,
//               );
//             } else if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.hasError) {
//               showDialog(
//                   context: context,
//                   builder: (_) => const ErrorDialog(
//                         title: 'Error Loading Orders 😅',
//                         content:
//                             'Maybe Internet Issue or... There are no orders! (Hint: Add some! 🤭)',
//                         buttonMessage: 'Gotcha! 😼',
//                       ));
//               return const SweatSmileImage();
//             } else {
//               return const SweatSmileImage();
//             }
//           })