import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/services/cloudinary_service.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatar(user?.nombre ?? '', user?.fotoUrl),
            const SizedBox(height: 16),
            Text(
              user?.nombre ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, user != null && user.telefono.isNotEmpty ? user.telefono : 'Sin teléfono'),
            if (user?.isAdmin == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings, color: AppColors.gold, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Administrador',
                      style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditDialog(context, auth),
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
              ),
            ),
            if (user?.isAdmin == true) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.adminPanel),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Ir al Panel de Admin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  auth.logout().then((_) {
                    showAppSnackBar(context, 'Sesión cerrada correctamente', type: SnackType.info);
                    context.go(AppRoutes.login);
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String nombre, String? fotoUrl) {
    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.card,
        backgroundImage: NetworkImage(fotoUrl),
      );
    }
    final iniciales = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.gold,
      child: Text(
        iniciales,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: AppColors.grey)),
      ],
    );
  }

  void _showEditDialog(BuildContext context, AuthProvider auth) {
    final nombreCtrl = TextEditingController(text: auth.user?.nombre ?? '');
    final telefonoCtrl = TextEditingController(text: auth.user?.telefono ?? '');
    String? fotoUrl = auth.user?.fotoUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Editar Perfil',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showPhotoOptions(context, (url) {
                    setDialogState(() => fotoUrl = url);
                  }),
                  child: Stack(
                    children: [
                      _buildAvatar(auth.user?.nombre ?? '', fotoUrl),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Nombre completo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefonoCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Teléfono'),
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
                Navigator.pop(ctx);
                await auth.updateProfile(
                  nombre: nombreCtrl.text.trim(),
                  telefono: telefonoCtrl.text.trim(),
                  fotoUrl: fotoUrl,
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, void Function(String) onUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Cambiar foto', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.gold),
                title: const Text('Galería', style: TextStyle(color: AppColors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final xfile = await CloudinaryService.pickFromGallery();
                  if (xfile == null) return;
                  final url = await CloudinaryService.uploadFile(xfile);
                  if (url != null && context.mounted) {
                    onUrl(url);
                    showAppSnackBar(context, 'Foto actualizada', type: SnackType.success);
                  } else if (context.mounted) {
                    showAppSnackBar(context, 'Error al subir foto', type: SnackType.error);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.gold),
                title: const Text('Desde URL', style: TextStyle(color: AppColors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUrlPhotoDialog(context, onUrl);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUrlPhotoDialog(BuildContext context, void Function(String) onUrl) {
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
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
              final url = await CloudinaryService.uploadFromUrl(urlCtrl.text.trim());
              if (url != null && context.mounted) {
                onUrl(url);
                showAppSnackBar(context, 'Foto actualizada', type: SnackType.success);
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
    );
  }
}
