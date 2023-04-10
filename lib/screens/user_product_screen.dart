import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:flutter_shop_app/screens/edit_product_screen.dart';
import 'package:flutter_shop_app/widgets/app_drawer.dart';
import 'package:flutter_shop_app/widgets/user_product_item.dart';
import "package:provider/provider.dart";

class UserProductScreen extends StatelessWidget {
  static const routeName = "/user-product";
  const UserProductScreen({Key? key}) : super(key: key);

  Future<void> _refreshProduct(BuildContext context) async {
    Provider.of<Products>(context, listen: false).fetchAndSetProduct();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Product"),
        actions: [IconButton(onPressed: () {
          Navigator.of(context).pushNamed(EditProductScreen.routeName);
        }, icon: Icon(Icons.add))],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProduct(context) ,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (_, i) => Column(
              children: [
                UserProductItem(
                  id: productData.items[i].id,
                    title: productData.items[i].title,
                    imageUrl: productData.items[i].imageUrl),
                Divider()
              ],
            ),
            itemCount: productData.items.length,
          ),
        ),
      ),
    );
  }
}
