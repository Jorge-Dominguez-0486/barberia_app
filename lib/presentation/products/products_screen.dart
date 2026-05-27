import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/category_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final _categoryRepo = CategoryRepository();
  List<CategoryModel> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryRepo.getCategories();
    setState(() => _categories = cats);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          if (cart.itemCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => context.push(AppRoutes.cart),
                ),
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
                      '${cart.itemCount}',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.grey),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().searchProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() {});
                context.read<ProductProvider>().searchProducts(v);
              },
            ),
          ),
          if (_categories.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length + 1,
                itemBuilder: (_, i) {
                  final isSelected = (i == 0 && _selectedCategory == null) ||
                      (i > 0 && _categories[i - 1].id == _selectedCategory);
                  final label = i == 0 ? 'Todos' : _categories[i - 1].nombre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = i == 0 ? null : _categories[i - 1].id;
                        });
                        context.read<ProductProvider>().filterByCategory(_selectedCategory);
                      },
                      selectedColor: AppColors.gold,
                      checkmarkColor: AppColors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.black : AppColors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.card,
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron productos',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (_, i) =>
                            _buildProductCard(context, productProvider.products[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.cart),
              backgroundColor: AppColors.gold,
              icon: const Icon(Icons.shopping_cart, color: AppColors.black),
              label: Text(
                'Ir al carrito (${cart.itemCount})',
                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildProductCard(BuildContext context, product) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.productDetailPath(product.id), extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: product.imagenUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            product.imagenUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.inventory,
                              color: AppColors.gold,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(Icons.inventory, color: AppColors.gold, size: 40),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                        ),
                        child: const Text('Agregar', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
