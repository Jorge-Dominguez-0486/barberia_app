import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _repo = UserRepository();
  final _searchCtrl = TextEditingController();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
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
        title: const Text('Usuarios'),
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
                hintText: 'Buscar por nombre o email...',
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
            child: StreamBuilder<List<UserModel>>(
              stream: _repo.streamUsers(),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        const Text('Error al cargar usuarios', style: TextStyle(color: AppColors.error, fontSize: 16)),
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

                var users = snapshot.data!;
                if (_query.isNotEmpty) {
                  users = users.where((u) =>
                    u.nombre.toLowerCase().contains(_query) ||
                    u.email.toLowerCase().contains(_query)
                  ).toList();
                }

                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: AppColors.grey),
                        SizedBox(height: 12),
                        Text('No hay usuarios registrados', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: users.length,
                  itemBuilder: (_, i) => _buildUserCard(context, users[i]),
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

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.gold,
              child: Text(
                user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
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
                          user.nombre,
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.isAdmin
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : AppColors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          user.isAdmin ? 'Admin' : 'Cliente',
                          style: TextStyle(
                            color: user.isAdmin ? AppColors.gold : AppColors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(color: AppColors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (user.telefono.isNotEmpty)
                    Text(user.telefono, style: const TextStyle(color: AppColors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Switch(
              value: user.isAdmin,
              onChanged: (val) => _toggleAdmin(user, val),
              activeThumbColor: AppColors.gold,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.grey),
              color: AppColors.card,
              onSelected: (opt) {
                if (opt == 'edit') _showEditDialog(context, user);
                if (opt == 'delete') _confirmDelete(context, user);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(
                  leading: Icon(Icons.edit, color: AppColors.gold),
                  title: Text('Editar', style: TextStyle(color: AppColors.white)),
                  dense: true,
                )),
                const PopupMenuItem(value: 'delete', child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title: Text('Eliminar', style: TextStyle(color: AppColors.error)),
                  dense: true,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAdmin(UserModel user, bool isAdmin) async {
    await _repo.updateUser(user.id, {'isAdmin': isAdmin});
    if (mounted) showAppSnackBar(context, 'Rol actualizado', type: SnackType.success);
  }

  void _showAddDialog(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Agregar Usuario', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Nombre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefonoCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Teléfono'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'El usuario deberá registrarse desde la app para obtener contraseña.',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('¿Admin?', style: TextStyle(color: AppColors.white)),
                    const Spacer(),
                    Switch(
                      value: isAdmin,
                      onChanged: (v) => setDialogState(() => isAdmin = v),
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
                if (nombreCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                final id = _firestore.collection('users').doc().id;
                final user = UserModel(
                  id: id,
                  nombre: nombreCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  telefono: telefonoCtrl.text.trim(),
                  isAdmin: isAdmin,
                );
                await _repo.createUser(user);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Usuario creado correctamente', type: SnackType.success);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserModel user) {
    final nombreCtrl = TextEditingController(text: user.nombre);
    final telefonoCtrl = TextEditingController(text: user.telefono);
    bool isAdmin = user.isAdmin;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar: ${user.nombre}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Nombre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefonoCtrl,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Teléfono'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('¿Admin?', style: TextStyle(color: AppColors.white)),
                    const Spacer(),
                    Switch(
                      value: isAdmin,
                      onChanged: (v) => setDialogState(() => isAdmin = v),
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
                await _repo.updateUser(user.id, {
                  'nombre': nombreCtrl.text.trim(),
                  'telefono': telefonoCtrl.text.trim(),
                  'isAdmin': isAdmin,
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Usuario actualizado', type: SnackType.success);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar usuario', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Seguro que deseas eliminar a ${user.nombre}?',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _repo.deleteUser(user.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                showAppSnackBar(context, 'Usuario eliminado', type: SnackType.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.white)),
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
