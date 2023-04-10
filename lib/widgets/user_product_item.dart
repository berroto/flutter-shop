import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:flutter_shop_app/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;

  const UserProductItem(
      {Key? key, required this.id, required this.title, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false).deleteProduct(
                        id);
                  } catch (error) {
                    scaffoldMessengerState.showSnackBar(SnackBar(content: Text("Delete failed")));
                  }
                },
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor)
          ],
        ),
      ),
    );
  }
}
