import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await _repository.getProducts().timeout(const Duration(seconds: 15));
      _filteredProducts = List.from(_allProducts);
    } on TimeoutException {
      _error = 'Error de conexión: el servidor no responde';
    } catch (e) {
      _error = 'Error al cargar productos';
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ProductModel> getProductsByCategory(String categoriaId) {
    return _allProducts.where((p) => p.categoriaId == categoriaId).toList();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String? categoriaId) {
    if (categoriaId == null) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((p) => p.categoriaId == categoriaId)
          .toList();
    }
    notifyListeners();
  }
}
