import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/cart_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth > 600 ? 32.0 : 16.0;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (context.watch<AuthProvider>().user?.isAdmin == true)
              _buildAdminBanner(context),
            _buildWelcome(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Servicios Destacados'),
            const SizedBox(height: 12),
            _buildServicesList(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Productos Destacados'),
            const SizedBox(height: 12),
            _buildProductsGrid(context, crossAxisCount),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.adminPanel),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF252540)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldGlow),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings, color: AppColors.gold, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Panel de Administración',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    final nombre = context.watch<AuthProvider>().user?.nombre ?? 'Usuario';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $nombre',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '¿Qué te gustaría hacer hoy?',
          style: TextStyle(fontSize: 14, color: AppColors.grey, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.goldGradient),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(BuildContext context) {
    final services = context.watch<ServiceProvider>().services;
    final isLoading = context.watch<ServiceProvider>().isLoading;

    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (services.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.content_cut_outlined, size: 36, color: AppColors.grey),
              SizedBox(height: 8),
              Text('No hay servicios disponibles', style: TextStyle(color: AppColors.grey, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final service = services[i];
          return Container(
            width: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldGlow, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: service.imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            service.imagenUrl!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (_, __, ___) => Icon(Icons.content_cut, color: AppColors.gold, size: 24),
                          ),
                        )
                      : const Icon(Icons.content_cut, color: AppColors.gold, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  service.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${service.precio.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context, int crossAxisCount) {
    final products = context.watch<ProductProvider>().products;
    final isLoading = context.watch<ProductProvider>().isLoading;

    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.grey),
              SizedBox(height: 8),
              Text('No hay productos disponibles', style: TextStyle(color: AppColors.grey, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final displayProducts = products.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayProducts.length,
      itemBuilder: (_, i) => _buildProductCard(context, displayProducts[i]),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldGlow, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: product.imagenUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.inventory, color: AppColors.gold, size: 36),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.inventory, color: AppColors.gold, size: 36),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.precio.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartProvider>().addItem(CartItemModel(
                        productId: product.id,
                        nombre: product.nombre,
                        precio: product.precio,
                        imagenUrl: product.imagenUrl,
                      ));
                      showAppSnackBar(context, 'Agregado al carrito', type: SnackType.success);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Agregar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
