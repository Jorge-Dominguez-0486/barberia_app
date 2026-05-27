import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/service_model.dart';
import '../data/repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _repository = ServiceRepository();

  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _repository.getServices().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      _error = 'Error de conexión: el servidor no responde';
    } catch (e) {
      _error = 'Error al cargar servicios';
    }

    _isLoading = false;
    notifyListeners();
  }
}
