import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> updateOrderStatus(String id, String estado) async {
    await _firestore.collection('orders').doc(id).update({'estado': estado});
  }
}
