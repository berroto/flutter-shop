import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/auth.dart';
import 'package:flutter_shop_app/screens/orders_screen.dart';
import 'package:flutter_shop_app/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

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
      Divider(),
      ListTile(
        leading: Icon(Icons.edit),
        title: Text("User Product"),
        onTap: (){
          Navigator.of(context).pushReplacementNamed(UserProductScreen.routeName);
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text("Logout"),
        onTap: (){
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed("/");
          Provider.of<Auth>(context, listen: false).logout();
        },
      ),
    ],),);
  }
}
