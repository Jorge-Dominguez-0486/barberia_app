import 'package:flutter/material.dart';
import '../data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  void addItem(CartItemModel item) {
    final index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index].cantidad += item.cantidad;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void addItemWithQuantity(CartItemModel item, int cantidad) {
    final index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index].cantidad += cantidad;
    } else {
      item.cantidad = cantidad;
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int cantidad) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (cantidad <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].cantidad = cantidad;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
