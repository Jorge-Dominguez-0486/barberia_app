import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/product_model.dart';
import '../data/models/service_model.dart';
import '../data/models/appointment_model.dart';
import '../data/models/category_model.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/appointment_repository.dart';

class AdminProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();
  final ProductRepository _productRepo = ProductRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  List<UserModel> _users = [];
  List<ProductModel> _products = [];
  List<ServiceModel> _services = [];
  List<AppointmentModel> _appointments = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  List<ProductModel> get products => _products;
  List<ServiceModel> get services => _services;
  List<AppointmentModel> get appointments => _appointments;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userRepo.getAllUsers();
      _products = await _productRepo.getProducts();
      _services = await _serviceRepo.getServices();
      _appointments = await _appointmentRepo.getAllAppointments();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    await _productRepo.createProduct(product);
    await loadAll();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _productRepo.updateProduct(id, data);
    await loadAll();
  }

  Future<void> deleteProduct(String id) async {
    await _productRepo.deleteProduct(id);
    await loadAll();
  }

  Future<void> addService(ServiceModel service) async {
    await _serviceRepo.createService(service);
    await loadAll();
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _serviceRepo.updateService(id, data);
    await loadAll();
  }

  Future<void> deleteService(String id) async {
    await _serviceRepo.deleteService(id);
    await loadAll();
  }
}
