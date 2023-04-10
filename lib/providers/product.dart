import 'package:flutter/material.dart';

class Product with ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite = false;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false
  });

  static Product fromJson(map){
    final p = Product(
        id: map['id'],
        title: map['title'],
        description: map["description"],
        imageUrl: map["imageUrl"],
        price: map["price"],
        isFavorite: map["isFavorite"]);
    return p;
  }

  void toggleFavoriteStatus(){
    isFavorite = !isFavorite;
    notifyListeners();
  }
}