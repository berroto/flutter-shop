import 'package:flutter/material.dart';
import 'package:flutter_shop_app/screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(child: Column(children: [
      AppBar(title: Text ("Hello Friends"),automaticallyImplyLeading: false,
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.shop),
        title: Text("shop"),
        onTap: (){
          Navigator.of(context).pushReplacementNamed("/");
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.payment),
        title: Text("orders"),
        onTap: (){
          Navigator.of(context).pushReplacementNamed(OrdersScreen.ROUTE_NAME);
        },
      ),
    ],),);
  }
}
