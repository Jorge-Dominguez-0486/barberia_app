import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final product = GoRouterState.of(context).extra as ProductModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push(AppRoutes.cart),
              ),
              if (context.watch<CartProvider>().itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${context.watch<CartProvider>().itemCount}',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (_, constraints) {
          final isSmall = constraints.maxWidth < 360;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isSmall ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: isSmall ? 180 : 250,
                    height: isSmall ? 180 : 250,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: product.imagenUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              product.imagenUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.inventory,
                                color: AppColors.gold,
                                size: 60,
                              ),
                            ),
                          )
                        : const Icon(Icons.inventory, color: AppColors.gold, size: 60),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  product.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.precio.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  product.descripcion,
                  style: const TextStyle(fontSize: 15, color: AppColors.grey, height: 1.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Stock disponible: ${product.stock}',
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Cantidad:',
                      style: TextStyle(fontSize: 16, color: AppColors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.gold),
                            onPressed: () {
                              if (_cantidad > 1) {
                                setState(() => _cantidad--);
                              }
                            },
                          ),
                          Text(
                            '$_cantidad',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.gold),
                            onPressed: () {
                              if (_cantidad < product.stock) {
                                setState(() => _cantidad++);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<CartProvider>().addItem(CartItemModel(
                        productId: product.id,
                        nombre: product.nombre,
                        precio: product.precio,
                        imagenUrl: product.imagenUrl,
                        cantidad: _cantidad,
                      ));
                      showAppSnackBar(context, '$_cantidad x ${product.nombre} agregado al carrito', type: SnackType.success);
                      setState(() => _cantidad = 1);
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Agregar al Carrito'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.cart),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Ir al Carrito'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
