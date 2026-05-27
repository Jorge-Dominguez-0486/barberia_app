import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/seed_data.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _loading = false;

  final List<_AdminSection> _sections = const [
    _AdminSection('Usuarios', 'Gestiona los usuarios registrados', Icons.people, AppRoutes.adminUsers),
    _AdminSection('Productos', 'Administra el catálogo de productos', Icons.inventory, AppRoutes.adminProducts),
    _AdminSection('Servicios', 'Configura los servicios ofrecidos', Icons.content_cut, AppRoutes.adminServices),
    _AdminSection('Citas', 'Revisa y administra las citas', Icons.calendar_month, AppRoutes.adminAppointments),
    _AdminSection('Categorías', 'Organiza las categorías', Icons.category, AppRoutes.adminCategories),
  ];

  Future<void> _seedData() async {
    setState(() => _loading = true);
    try {
      await seedFirestore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos cargados correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Ver app de cliente',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth > 600 ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: AppColors.gold, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bienvenido al panel de administración',
                    style: TextStyle(fontSize: 16, color: AppColors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _sections.length,
                itemBuilder: (_, i) => _buildCard(context, _sections[i]),
              ),
            ),
            Center(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.grey),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: _seedData,
                      icon: const Icon(Icons.storage, size: 16),
                      label: const Text('Cargar datos de ejemplo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.grey,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _AdminSection section) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push(section.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(section.icon, color: AppColors.gold, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                section.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                section.description,
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSection {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _AdminSection(this.title, this.description, this.icon, this.route);
}
