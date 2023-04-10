import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/product.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];/* = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];*/

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http
          .post(Uri.http("localhost:8087", "/products"),
          headers: {
            "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json',
            'Accept': '*/*'
          },
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'id': product.id,
            'isFavorite': product.isFavorite,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final map = json.decode(response.body);
      final newProduct = Product(
          id: map['id'],
          title: map['title'],
          description: map["description"],
          imageUrl: map["imageUrl"],
          price: map["price"],
          isFavorite: map["isFavorite"]);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error!;
    }
  }

  Future<void> editProduct(Product product) async {
    final prodIndex = _items.indexWhere((element) => element.id == product.id);
    if (prodIndex > 0) {
      final response = await http
          .patch(Uri.http("localhost:8087", "/products/${product.id}"),
          headers: {
            "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json',
            'Accept': '*/*'
          },
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final map = json.decode(response.body);
      _items[prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProduct() async{
    try {
      final response = await http
          .get(Uri.http("localhost:8087", "/products"),
          headers: {
            "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json',
            'Accept': '*/*'
          });
      _items=(json.decode(response.body) as List).map((i) =>
          Product.fromJson(i)).toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error!;
    }
  }

  Future<void>  deleteProduct(String id) async{
    try {
      final response = await http
          .delete(Uri.http("localhost:8087", "/products/${id}"),
          headers: {
            "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json',
            'Accept': '*/*'
          });
      if ( response.statusCode > 399){
        throw const HttpException("Delete do worked");
      }
      //final map = json.decode(response.body);
      _items.removeWhere((element) => element.id == id);
    } catch (error) {
      print(error);
      throw error!;
    }
    notifyListeners();
  }
}
