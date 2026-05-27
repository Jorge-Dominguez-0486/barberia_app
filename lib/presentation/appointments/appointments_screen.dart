import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/service_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      context.read<AppointmentProvider>().getMyAppointments(userId);
    }
    context.read<ServiceProvider>().loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.grey,
          tabs: const [
            Tab(text: 'Mis Citas'),
            Tab(text: 'Nueva Cita'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MisCitasTab(),
          _NuevaCitaTab(onCreada: () {
            _tabController.animateTo(0);
            _loadData();
          }),
        ],
      ),
    );
  }
}

class _MisCitasTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 60, color: AppColors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes citas agendadas',
              style: TextStyle(fontSize: 18, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.appointments.length,
      itemBuilder: (_, i) {
        final appt = provider.appointments[i];
        return _buildAppointmentCard(context, appt, provider);
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, appt, AppointmentProvider provider) {
    Color colorEstado;
    IconData iconEstado;
    switch (appt.estado) {
      case 'confirmada':
        colorEstado = AppColors.success;
        iconEstado = Icons.check_circle;
        break;
      case 'cancelada':
        colorEstado = AppColors.error;
        iconEstado = Icons.cancel;
        break;
      default:
        colorEstado = AppColors.gold;
        iconEstado = Icons.schedule;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorEstado.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconEstado, color: colorEstado, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.serviceNombre,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(appt.fecha)} - ${appt.hora}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appt.estado.toUpperCase(),
                      style: TextStyle(
                        color: colorEstado,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (appt.estado == 'pendiente')
              TextButton(
                onPressed: () => _confirmCancel(context, appt.id, provider),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String id, AppointmentProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Cancelar cita', style: TextStyle(color: AppColors.white)),
        content: const Text('¿Estás seguro de cancelar esta cita?', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.cancelAppointment(id);
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _NuevaCitaTab extends StatefulWidget {
  final VoidCallback onCreada;
  const _NuevaCitaTab({required this.onCreada});

  @override
  State<_NuevaCitaTab> createState() => _NuevaCitaTabState();
}

class _NuevaCitaTabState extends State<_NuevaCitaTab> {
  final _notasController = TextEditingController();
  String? _selectedServiceId;
  String? _selectedServiceNombre;
  DateTime? _selectedDate;
  String? _selectedHora;
  bool _isSubmitting = false;

  final List<String> _horas = [];

  @override
  void initState() {
    super.initState();
    for (int h = 9; h <= 18; h++) {
      for (int m = 0; m < 60; m += 30) {
        if (h == 18 && m > 0) break;
        _horas.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      }
    }
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: AppColors.black,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedServiceId == null) {
      _showError('Selecciona un servicio');
      return;
    }
    if (_selectedDate == null) {
      _showError('Selecciona una fecha');
      return;
    }
    if (_selectedHora == null) {
      _showError('Selecciona una hora');
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      _showError('Debes iniciar sesión');
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<AppointmentProvider>();

    await provider.createAppointment(
      clienteId: auth.user!.id,
      clienteNombre: auth.user!.nombre,
      serviceId: _selectedServiceId!,
      serviceNombre: _selectedServiceNombre ?? '',
      fecha: _selectedDate!,
      hora: _selectedHora!,
      notas: _notasController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (provider.error == null) {
        showAppSnackBar(context, 'Cita agendada correctamente', type: SnackType.success);
        setState(() {
          _selectedServiceId = null;
          _selectedServiceNombre = null;
          _selectedDate = null;
          _selectedHora = null;
          _notasController.clear();
        });
        widget.onCreada();
      } else {
        showAppSnackBar(context, provider.error!, type: SnackType.error);
      }
    }
  }

  void _showError(String msg) {
    showAppSnackBar(context, msg, type: SnackType.error);
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final services = serviceProvider.services;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agendar nueva cita',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 24),
          _buildLabel('Servicio'),
          const SizedBox(height: 8),
          serviceProvider.isLoading
              ? const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _selectedServiceId,
                  decoration: _inputDecoration(),
                  hint: const Text('Selecciona un servicio', style: TextStyle(color: AppColors.grey)),
                  dropdownColor: AppColors.card,
                  items: services.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '${s.nombre} - \$${s.precio.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final service = services.where((s) => s.id == val).firstOrNull;
                    setState(() {
                      _selectedServiceId = val;
                      _selectedServiceNombre = service?.nombre;
                    });
                  },
                ),
          const SizedBox(height: 20),
          _buildLabel('Fecha'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'Selecciona una fecha',
                    style: TextStyle(
                      color: _selectedDate != null ? AppColors.white : AppColors.grey,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: AppColors.gold),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Hora'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _horas.map((h) {
              final selected = _selectedHora == h;
              return GestureDetector(
                onTap: () => setState(() => _selectedHora = h),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.gold : AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? AppColors.gold : AppColors.darkGrey,
                    ),
                  ),
                  child: Text(
                    h,
                    style: TextStyle(
                      color: selected ? AppColors.black : AppColors.white,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildLabel('Notas (opcional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notasController,
            decoration: _inputDecoration(hint: 'Algún comentario adicional...'),
            maxLines: 3,
            style: const TextStyle(color: AppColors.white),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                    )
                  : const Text('Agendar Cita'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
