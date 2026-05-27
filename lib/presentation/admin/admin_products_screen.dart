import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/services/cloudinary_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _repo = ProductRepository();
  final _catRepo = CategoryRepository();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _categoryFilter;
  List<CategoryModel> _categories = [];
  Map<String, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _catRepo.getCategories();
    setState(() {
      _categories = cats;
      _categoryNames = {for (var c in cats) c.id: c.nombre};
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Ver app de cliente',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          if (_categories.isNotEmpty)
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length + 1,
                itemBuilder: (_, i) {
                  final isSelected = (i == 0 && _categoryFilter == null) ||
                      (i > 0 && _categories[i - 1].id == _categoryFilter);
                  final label = i == 0 ? 'Todos' : _categories[i - 1].nombre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _categoryFilter = i == 0 ? null : _categories[i - 1].id;
                        });
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
            child: StreamBuilder<List<ProductModel>>(
              stream: _repo.streamAllProducts(),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        const Text('Error al cargar productos', style: TextStyle(color: AppColors.error, fontSize: 16)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data!;
                if (_query.isNotEmpty) {
                  products = products.where((p) => p.nombre.toLowerCase().contains(_query)).toList();
                }
                if (_categoryFilter != null) {
                  products = products.where((p) => p.categoriaId == _categoryFilter).toList();
                }

                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.grey),
                        SizedBox(height: 12),
                        Text('No hay productos disponibles', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _buildProductCard(context, products[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add, color: AppColors.black),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final catName = _categoryNames[product.categoriaId] ?? 'Sin categoría';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.imagenUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imagenUrl!,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        errorBuilder: (_, __, ___) => const Icon(Icons.inventory, color: AppColors.gold),
                      ),
                    )
                  : const Icon(Icons.inventory, color: AppColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nombre,
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.activo
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: product.activo ? AppColors.success : AppColors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.precio.toStringAsFixed(2)}  |  Stock: ${product.stock}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  Text(
                    catName,
                    style: const TextStyle(color: AppColors.gold, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    product.activo ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    _repo.updateProduct(product.id, {'activo': !product.activo});
                    showAppSnackBar(context, product.activo ? 'Producto desactivado' : 'Producto activado', type: SnackType.info);
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.gold, size: 18),
                      onPressed: () => _showEditDialog(context, product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                      onPressed: () => _confirmDelete(context, product),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '0');
    bool activo = true;
    String? selectedCat;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Agregar Producto', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Nombre *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Precio *'),
                ),
                const SizedBox(height: 10),
                _buildImageSection(imageUrlCtrl, setDialogState),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: _inputDecoration('Categoría'),
                  hint: const Text('Seleccionar', style: TextStyle(color: AppColors.grey)),
                  dropdownColor: AppColors.card,
                  items: _categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.nombre, style: const TextStyle(color: AppColors.white)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedCat = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stockCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Stock'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Activo', style: TextStyle(color: AppColors.white)),
                    const Spacer(),
                    Switch(
                      value: activo,
                      onChanged: (v) => setDialogState(() => activo = v),
                      activeThumbColor: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.trim().isEmpty) return;
                final precio = double.tryParse(precioCtrl.text.trim()) ?? 0;
                final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                final id = _firestore.collection('products').doc().id;
                final product = ProductModel(
                  id: id,
                  nombre: nombreCtrl.text.trim(),
                  descripcion: descCtrl.text.trim(),
                  precio: precio,
                  categoriaId: selectedCat ?? '',
                  imagenUrl: imageUrlCtrl.text.trim().isEmpty ? null : imageUrlCtrl.text.trim(),
                  stock: stock,
                  activo: activo,
                );
                await _repo.createProduct(product);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Producto creado', type: SnackType.success);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductModel product) {
    final nombreCtrl = TextEditingController(text: product.nombre);
    final descCtrl = TextEditingController(text: product.descripcion);
    final precioCtrl = TextEditingController(text: product.precio.toString());
    final imageUrlCtrl = TextEditingController(text: product.imagenUrl ?? '');
    final stockCtrl = TextEditingController(text: product.stock.toString());
    bool activo = product.activo;
    String? selectedCat = product.categoriaId.isNotEmpty ? product.categoriaId : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar: ${product.nombre}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Nombre *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Precio *'),
                ),
                const SizedBox(height: 10),
                _buildImageSection(imageUrlCtrl, setDialogState),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: _inputDecoration('Categoría'),
                  hint: const Text('Seleccionar', style: TextStyle(color: AppColors.grey)),
                  dropdownColor: AppColors.card,
                  items: _categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.nombre, style: const TextStyle(color: AppColors.white)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedCat = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stockCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Stock'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Activo', style: TextStyle(color: AppColors.white)),
                    const Spacer(),
                    Switch(
                      value: activo,
                      onChanged: (v) => setDialogState(() => activo = v),
                      activeThumbColor: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.trim().isEmpty) return;
                final precio = double.tryParse(precioCtrl.text.trim()) ?? 0;
                final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                await _repo.updateProduct(product.id, {
                  'nombre': nombreCtrl.text.trim(),
                  'descripcion': descCtrl.text.trim(),
                  'precio': precio,
                  'categoriaId': selectedCat ?? '',
                  'imagenUrl': imageUrlCtrl.text.trim().isEmpty ? null : imageUrlCtrl.text.trim(),
                  'stock': stock,
                  'activo': activo,
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Producto actualizado', type: SnackType.success);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Seguro que deseas eliminar ${product.nombre}?',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _repo.deleteProduct(product.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                showAppSnackBar(context, 'Producto eliminado', type: SnackType.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(TextEditingController ctrl, StateSetter setDialogState) {
    return Column(
      children: [
        if (ctrl.text.isNotEmpty)
          Container(
            height: 80,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ctrl.text,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: AppColors.grey),
                ),
              ),
            ),
          ),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.white, fontSize: 13),
          decoration: _inputDecoration('URL de imagen (o sube una)'),
          onChanged: (_) => setDialogState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final xfile = await CloudinaryService.pickFromGallery();
                    if (xfile == null) return;
                    setDialogState(() => ctrl.text = '');
                    final url = await CloudinaryService.uploadFile(xfile);
                    if (url != null && context.mounted) {
                      setDialogState(() => ctrl.text = url);
                      showAppSnackBar(context, 'Imagen subida correctamente', type: SnackType.success);
                    } else if (context.mounted) {
                      showAppSnackBar(context, 'Error al subir imagen', type: SnackType.error);
                    }
                  },
                  icon: const Icon(Icons.photo_library, size: 14),
                  label: const Text('Galería', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => _showUrlUploadDialog(context, ctrl, setDialogState),
                  icon: const Icon(Icons.link, size: 14),
                  label: const Text('Desde URL', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showUrlUploadDialog(BuildContext ctx, TextEditingController ctrl, StateSetter setDialogState) {
    final urlCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Subir desde URL', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: urlCtrl,
          style: const TextStyle(color: AppColors.white),
          decoration: _inputDecoration('URL de GitHub o imagen'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlCtrl.text.trim().isEmpty) return;
              Navigator.pop(dCtx);
              setDialogState(() => ctrl.text = '');
              final url = await CloudinaryService.uploadFromUrl(urlCtrl.text.trim());
              if (url != null && context.mounted) {
                setDialogState(() => ctrl.text = url);
                showAppSnackBar(context, 'Imagen subida correctamente', type: SnackType.success);
              } else if (context.mounted) {
                showAppSnackBar(context, 'Error al subir desde URL', type: SnackType.error);
              }
            },
            child: const Text('Subir'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.grey),
      filled: true,
      fillColor: AppColors.darkGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
