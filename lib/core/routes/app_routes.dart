class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String appointments = '/appointments';
  static const String profile = '/profile';
  static const String adminPanel = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminServices = '/admin/services';
  static const String adminAppointments = '/admin/appointments';
  static const String adminCategories = '/admin/categories';

  static String productDetailPath(String id) => '/product/$id';
}
