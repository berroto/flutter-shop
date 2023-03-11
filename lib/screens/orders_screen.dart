import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/orders.dart';
import 'package:flutter_shop_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shop_app/widgets/order_item.dart' as oi;

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const ROUTE_NAME = "/orders";

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(itemBuilder: (ctx, i) => oi.OrderItem(order: orders.orders[i]), itemCount: orders.orders.length,),
    );
  }
}
