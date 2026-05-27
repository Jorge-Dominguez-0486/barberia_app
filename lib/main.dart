import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/routes/app_routes.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/service_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/admin_provider.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/products/products_screen.dart';
import 'presentation/products/product_detail_screen.dart';
import 'presentation/cart/cart_screen.dart';
import 'presentation/appointments/appointments_screen.dart';
import 'presentation/profile/profile_screen.dart';
import 'presentation/admin/admin_panel_screen.dart';
import 'presentation/admin/admin_users_screen.dart';
import 'presentation/admin/admin_products_screen.dart';
import 'presentation/admin/admin_services_screen.dart';
import 'presentation/admin/admin_appointments_screen.dart';
import 'presentation/admin/admin_categories_screen.dart';

class ClientShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ClientShell({super.key, required this.navigationShell});

  static const _navItems = [
    _NavItem('Inicio', Icons.home_outlined, Icons.home),
    _NavItem('Productos', Icons.shopping_bag_outlined, Icons.shopping_bag),
    _NavItem('Citas', Icons.calendar_month_outlined, Icons.calendar_month),
    _NavItem('Perfil', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopNav(context),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final auth = context.watch<AuthProvider>();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldGlow, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (auth.user?.isAdmin == true)
            GestureDetector(
              onTap: () => context.push(AppRoutes.adminPanel),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldGlow),
                ),
                child: const Icon(Icons.admin_panel_settings, color: AppColors.gold, size: 18),
              ),
            ),
          if (auth.user?.isAdmin == true) const SizedBox(width: 6),
          ...List.generate(_navItems.length, (i) {
            final isSelected = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => navigationShell.goBranch(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: AppColors.goldGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? _navItems[i].iconFilled : _navItems[i].iconOutlined,
                        color: isSelected ? AppColors.black : AppColors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _navItems[i].label,
                        style: TextStyle(
                          color: isSelected ? AppColors.black : AppColors.grey,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.grey, size: 20),
                onPressed: () => context.push(AppRoutes.cart),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              if (context.watch<CartProvider>().itemCount > 0)
                Positioned(
                  right: 4,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.goldGlow, blurRadius: 6),
                      ],
                    ),
                    child: Text(
                      '${context.watch<CartProvider>().itemCount}',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData iconOutlined;
  final IconData iconFilled;
  const _NavItem(this.label, this.iconOutlined, this.iconFilled);
}

final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    try {
      final auth = context.read<AuthProvider>();
      final loggedIn = auth.isLoggedIn;
      final location = state.uri.toString();

      if (!loggedIn && location != AppRoutes.login && location != AppRoutes.register) {
        return AppRoutes.login;
      }

      if (auth.user != null && !auth.user!.isAdmin && location.startsWith('/admin')) {
        return AppRoutes.home;
      }
    } catch (_) {}
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.splash, redirect: (_, __) => AppRoutes.home),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
    GoRoute(path: AppRoutes.productDetail, builder: (_, state) => const ProductDetailScreen()),
    GoRoute(path: AppRoutes.cart, builder: (_, __) => const CartScreen()),
    GoRoute(path: AppRoutes.adminPanel, builder: (_, __) => const AdminPanelScreen()),
    GoRoute(path: AppRoutes.adminUsers, builder: (_, __) => const AdminUsersScreen()),
    GoRoute(path: AppRoutes.adminProducts, builder: (_, __) => const AdminProductsScreen()),
    GoRoute(path: AppRoutes.adminServices, builder: (_, __) => const AdminServicesScreen()),
    GoRoute(path: AppRoutes.adminAppointments, builder: (_, __) => const AdminAppointmentsScreen()),
    GoRoute(path: AppRoutes.adminCategories, builder: (_, __) => const AdminCategoriesScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, __, navigationShell) => ClientShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.products, builder: (_, __) => const ProductsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.appointments, builder: (_, __) => const AppointmentsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen())],
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    FirebaseOptions? options;
    try {
      options = DefaultFirebaseOptions.currentPlatform;
    } catch (_) {}
    await Firebase.initializeApp(options: options);
  } catch (_) {}
  runApp(const BarberiaApp());
}

class BarberiaApp extends StatelessWidget {
  const BarberiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: 'Barbería App',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
