import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> createService(ServiceModel service) async {
    await _firestore.collection('services').doc(service.id).set(service.toMap());
  }

  Future<List<ServiceModel>> getServices() async {
    final snapshot = await _firestore.collection('services').get();
    return snapshot.docs.map((doc) => ServiceModel.fromMap(doc.data())).toList();
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _firestore.collection('services').doc(id).update(data);
  }

  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).delete();
  }

  Stream<List<ServiceModel>> streamAllServices() {
    return _firestore.collection('services').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ServiceModel.fromMap(doc.data())).toList(),
    );
  }
}
