import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price
  });
}

class Cart with ChangeNotifier {
    late Map<String, CartItem> _items = {};

    Map<String, CartItem> get items {
      return {..._items};
    }

    double get totalAmount {
      double total= 0.0;
      _items.forEach((key, value) {
        total += (value.price * value.quantity);
      });
      return total;
    }


    int get itemCount{
      if ( _items == null)
        return 0;
      return _items.length;
    }

    void addItem(String productId, double price, String title){
      if ( _items.containsKey(productId)){
        _items.update(productId, (value) => CartItem(id: productId, title: title, quantity: value.quantity+1, price: price));
      } else {
        _items.putIfAbsent(productId, () => CartItem(id: productId, title: title, quantity: 1, price: price));
      }
      notifyListeners();
    }

    void removeItem(String productId){
      _items.remove(productId);
      notifyListeners();
    }

    void clear(){
      _items.clear();
      notifyListeners();
    }
}