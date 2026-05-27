import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> createAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap())
        .timeout(const Duration(seconds: 15));
  }

  Future<List<AppointmentModel>> getAppointmentsByUser(String userId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('clienteId', isEqualTo: userId)
        .get()
        .timeout(const Duration(seconds: 15));
    return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data())).toList();
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    final snapshot = await _firestore
        .collection('appointments')
        .get()
        .timeout(const Duration(seconds: 15));
    return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data())).toList();
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection('appointments')
        .doc(id)
        .update(data)
        .timeout(const Duration(seconds: 15));
  }

  Future<void> deleteAppointment(String id) async {
    await _firestore
        .collection('appointments')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 15));
  }

  Stream<List<AppointmentModel>> streamAllAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data())).toList());
  }
}
