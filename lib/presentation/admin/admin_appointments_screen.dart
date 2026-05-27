import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/service_repository.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final _repo = AppointmentRepository();
  final _serviceRepo = ServiceRepository();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  String _statusFilter = 'Todas';

  final List<String> _horas = [];
  final List<String> _estados = ['Todas', 'pendiente', 'confirmada', 'cancelada'];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
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
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _repo.streamAllAppointments(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  const Text('Error al cargar citas', style: TextStyle(color: AppColors.error, fontSize: 16)),
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

          var all = snapshot.data!;
          final pendientes = all.where((a) => a.estado == 'pendiente').length;
          final confirmadas = all.where((a) => a.estado == 'confirmada').length;
          final canceladas = all.where((a) => a.estado == 'cancelada').length;

          if (_statusFilter != 'Todas') {
            all = all.where((a) => a.estado == _statusFilter).toList();
          }

          return Column(
            children: [
              _buildSummary(pendientes, confirmadas, canceladas),
              _buildFilter(),
              Expanded(
                child: all.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 48, color: AppColors.grey),
                            SizedBox(height: 12),
                            Text('No hay citas', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: all.length,
                        itemBuilder: (_, i) => _buildCard(context, all[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add, color: AppColors.black),
      ),
    );
  }

  Widget _buildSummary(int pendientes, int confirmadas, int canceladas) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _summaryCard('Pendientes', pendientes, AppColors.gold),
          const SizedBox(width: 8),
          _summaryCard('Confirmadas', confirmadas, AppColors.success),
          const SizedBox(width: 8),
          _summaryCard('Canceladas', canceladas, AppColors.error),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Text('Filtrar:', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  items: _estados.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e == 'Todas' ? 'Todas' : '${e[0].toUpperCase()}${e.substring(1)}',
                      style: const TextStyle(color: AppColors.white),
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _statusFilter = v!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, AppointmentModel appt) {
    Color colorEstado;
    switch (appt.estado) {
      case 'confirmada':
        colorEstado = AppColors.success;
        break;
      case 'cancelada':
        colorEstado = AppColors.error;
        break;
      default:
        colorEstado = AppColors.gold;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorEstado.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_today, color: colorEstado, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.clienteNombre,
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appt.serviceNombre,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(appt.fecha)} - ${appt.hora}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
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
                      style: TextStyle(color: colorEstado, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.gold, size: 20),
                  onPressed: () => _showEditDialog(context, appt),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(context, appt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppointmentModel appt) {
    String estado = appt.estado;
    final clienteCtrl = TextEditingController(text: appt.clienteNombre);
    final serviceCtrl = TextEditingController(text: appt.serviceNombre);
    DateTime fecha = appt.fecha;
    String hora = appt.hora;
    final notasCtrl = TextEditingController(text: appt.notas);
    final estados = ['pendiente', 'confirmada', 'cancelada'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Cita', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: estado,
                  decoration: _inputDecoration('Estado'),
                  dropdownColor: AppColors.card,
                  items: estados.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text('${e[0].toUpperCase()}${e.substring(1)}', style: const TextStyle(color: AppColors.white)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => estado = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: clienteCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Cliente'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: serviceCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Servicio'),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fecha,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                      builder: (_, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.gold, onPrimary: AppColors.black,
                            surface: AppColors.card,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setDialogState(() => fecha = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(fecha), style: const TextStyle(color: AppColors.white)),
                        const Icon(Icons.calendar_today, color: AppColors.gold, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: hora,
                  decoration: _inputDecoration('Hora'),
                  dropdownColor: AppColors.card,
                  items: _horas.map((h) => DropdownMenuItem(
                    value: h,
                    child: Text(h, style: const TextStyle(color: AppColors.white)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => hora = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notasCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _inputDecoration('Notas'),
                  maxLines: 2,
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
                await _repo.updateAppointment(appt.id, {
                  'estado': estado,
                  'clienteNombre': clienteCtrl.text.trim(),
                  'serviceNombre': serviceCtrl.text.trim(),
                  'fecha': fecha.toIso8601String(),
                  'hora': hora,
                  'notas': notasCtrl.text.trim(),
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Cita actualizada', type: SnackType.success);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    String estado = 'pendiente';
    final clienteCtrl = TextEditingController();
    String? selectedServiceId;
    String? selectedServiceNombre;
    DateTime fecha = DateTime.now().add(const Duration(days: 1));
    String? hora;
    final notasCtrl = TextEditingController();
    List<ServiceModel> services = [];
    bool loadingServices = true;
    final estados = ['pendiente', 'confirmada', 'cancelada'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) {
          if (loadingServices) {
            _serviceRepo.getServices().timeout(const Duration(seconds: 15)).then((s) {
              if (ctx.mounted) setDialogState(() { services = s; loadingServices = false; });
            }).catchError((_) {
              if (ctx.mounted) setDialogState(() => loadingServices = false);
            });
          }
          return AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Agregar Cita', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: clienteCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: _inputDecoration('Nombre del cliente *'),
                  ),
                  const SizedBox(height: 10),
                  loadingServices
                      ? const SizedBox(
                          height: 48,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: selectedServiceId,
                          decoration: _inputDecoration('Servicio'),
                          hint: const Text('Seleccionar', style: TextStyle(color: AppColors.grey)),
                          dropdownColor: AppColors.card,
                          items: services.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.nombre, style: const TextStyle(color: AppColors.white)),
                          )).toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            final s = services.where((s) => s.id == v).firstOrNull;
                            setDialogState(() {
                              selectedServiceId = v;
                              selectedServiceNombre = s?.nombre;
                            });
                          },
                        ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fecha,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                        builder: (_, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.gold, onPrimary: AppColors.black,
                              surface: AppColors.card,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setDialogState(() => fecha = picked);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(fecha), style: const TextStyle(color: AppColors.white)),
                          const Icon(Icons.calendar_today, color: AppColors.gold, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: hora,
                    decoration: _inputDecoration('Hora'),
                    hint: const Text('Seleccionar', style: TextStyle(color: AppColors.grey)),
                    dropdownColor: AppColors.card,
                    items: _horas.map((h) => DropdownMenuItem(
                      value: h,
                      child: Text(h, style: const TextStyle(color: AppColors.white)),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => hora = v),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notasCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: _inputDecoration('Notas'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: estado,
                    decoration: _inputDecoration('Estado'),
                    dropdownColor: AppColors.card,
                    items: estados.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text('${e[0].toUpperCase()}${e.substring(1)}', style: const TextStyle(color: AppColors.white)),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => estado = v!),
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
                  if (clienteCtrl.text.trim().isEmpty) return;
                  final id = _firestore.collection('appointments').doc().id;
                  final appt = AppointmentModel(
                    id: id,
                    clienteId: '',
                    clienteNombre: clienteCtrl.text.trim(),
                    serviceId: selectedServiceId ?? '',
                    serviceNombre: selectedServiceNombre ?? '',
                    fecha: fecha,
                    hora: hora ?? '09:00',
                    estado: estado,
                    notas: notasCtrl.text.trim(),
                  );
                  await _repo.createAppointment(appt);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    showAppSnackBar(context, 'Cita creada', type: SnackType.success);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppointmentModel appt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar cita', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Seguro que deseas eliminar la cita de ${appt.clienteNombre}?',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _repo.deleteAppointment(appt.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                showAppSnackBar(context, 'Cita eliminada', type: SnackType.success);
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
