import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String nombre;
  final double precio;
  final int cantidad;
  final String? imagenUrl;

  OrderItem({
    required this.productId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.imagenUrl,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'nombre': nombre,
        'precio': precio,
        'cantidad': cantidad,
        'imagenUrl': imagenUrl,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String,
        nombre: map['nombre'] as String,
        precio: (map['precio'] as num).toDouble(),
        cantidad: (map['cantidad'] as num).toInt(),
        imagenUrl: map['imagenUrl'] as String?,
      );
}

class OrderModel {
  final String id;
  final String userId;
  final String? userName;
  final List<OrderItem> items;
  final double total;
  final String paymentMethod;
  final Map<String, dynamic>? paymentDetails;
  final String estado;
  final DateTime fechaCreacion;

  OrderModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.paymentDetails,
    this.estado = 'pendiente',
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        if (paymentDetails != null) 'paymentDetails': paymentDetails,
        'estado': estado,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      };

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) => OrderModel(
        id: id,
        userId: map['userId'] as String,
        userName: map['userName'] as String?,
        items: (map['items'] as List).map((i) => OrderItem.fromMap(i as Map<String, dynamic>)).toList(),
        total: (map['total'] as num).toDouble(),
        paymentMethod: map['paymentMethod'] as String,
        paymentDetails: map['paymentDetails'] as Map<String, dynamic>?,
        estado: map['estado'] as String? ?? 'pendiente',
        fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      );
}
