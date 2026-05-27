import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/services/cloudinary_service.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _repo = CategoryRepository();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
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
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<CategoryModel>>(
              stream: _repo.streamAllCategories(),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        const Text('Error al cargar categorías', style: TextStyle(color: AppColors.error, fontSize: 16)),
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

                var categories = snapshot.data!;
                if (_query.isNotEmpty) {
                  categories = categories.where((c) => c.nombre.toLowerCase().contains(_query)).toList();
                }

                if (categories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 48, color: AppColors.grey),
                        SizedBox(height: 12),
                        Text('No hay categorías disponibles', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: categories.length,
                  itemBuilder: (_, i) => _buildCard(context, categories[i]),
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

  Widget _buildCard(BuildContext context, CategoryModel category) {
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
              child: category.imagenUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        category.imagenUrl!,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        errorBuilder: (_, __, ___) => const Icon(Icons.category, color: AppColors.gold),
                      ),
                    )
                  : const Icon(Icons.category, color: AppColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.nombre,
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      category.descripcion,
                      style: const TextStyle(color: AppColors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.gold, size: 20),
                  onPressed: () => _showEditDialog(context, category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(context, category),
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
    final imageUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Agregar Categoría', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
                _buildImageSection(imageUrlCtrl, setDialogState),
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
                final id = _firestore.collection('categories').doc().id;
                final category = CategoryModel(
                  id: id,
                  nombre: nombreCtrl.text.trim(),
                  descripcion: descCtrl.text.trim(),
                  imagenUrl: imageUrlCtrl.text.trim().isEmpty ? null : imageUrlCtrl.text.trim(),
                );
                await _repo.createCategory(category);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Categoría creada', type: SnackType.success);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, CategoryModel category) {
    final nombreCtrl = TextEditingController(text: category.nombre);
    final descCtrl = TextEditingController(text: category.descripcion);
    final imageUrlCtrl = TextEditingController(text: category.imagenUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar: ${category.nombre}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
                _buildImageSection(imageUrlCtrl, setDialogState),
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
              await _repo.updateCategory(category.id, {
                'nombre': nombreCtrl.text.trim(),
                'descripcion': descCtrl.text.trim(),
                'imagenUrl': imageUrlCtrl.text.trim().isEmpty ? null : imageUrlCtrl.text.trim(),
              });
              if (ctx.mounted) {
                Navigator.pop(ctx);
                showAppSnackBar(context, 'Categoría actualizada', type: SnackType.success);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar categoría', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Seguro que deseas eliminar ${category.nombre}?',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _repo.deleteCategory(category.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                showAppSnackBar(context, 'Categoría eliminada', type: SnackType.success);
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
