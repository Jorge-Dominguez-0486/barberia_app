import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/appointment_model.dart';
import '../data/repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository = AppointmentRepository();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createAppointment({
    required String clienteId,
    required String clienteNombre,
    required String serviceId,
    required String serviceNombre,
    required DateTime fecha,
    required String hora,
    String notas = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = _firestore.collection('appointments').doc().id;
      final appointment = AppointmentModel(
        id: id,
        clienteId: clienteId,
        clienteNombre: clienteNombre,
        serviceId: serviceId,
        serviceNombre: serviceNombre,
        fecha: fecha,
        hora: hora,
        notas: notas,
      );
      await _repository.createAppointment(appointment);
      _appointments.add(appointment);
    } on TimeoutException {
      _error = 'Error de conexión: el servidor no responde';
    } catch (e) {
      _error = 'Error al agendar la cita';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getMyAppointments(String clienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _repository.getAppointmentsByUser(clienteId);
    } on TimeoutException {
      _error = 'Error de conexión: el servidor no responde';
    } catch (e) {
      _error = 'Error al cargar citas';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _repository.updateAppointment(appointmentId, {'estado': 'cancelada'});
    } catch (_) {
      return;
    }
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index >= 0) {
      _appointments[index] = AppointmentModel(
        id: _appointments[index].id,
        clienteId: _appointments[index].clienteId,
        clienteNombre: _appointments[index].clienteNombre,
        serviceId: _appointments[index].serviceId,
        serviceNombre: _appointments[index].serviceNombre,
        fecha: _appointments[index].fecha,
        hora: _appointments[index].hora,
        estado: 'cancelada',
        notas: _appointments[index].notas,
      );
      notifyListeners();
    }
  }
}
