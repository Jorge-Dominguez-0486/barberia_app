class CartItemModel {
  final String productId;
  final String nombre;
  final double precio;
  final String? imagenUrl;
  int cantidad;

  CartItemModel({
    required this.productId,
    required this.nombre,
    required this.precio,
    this.imagenUrl,
    this.cantidad = 1,
  });

  double get total => precio * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'nombre': nombre,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'cantidad': cantidad,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      imagenUrl: map['imagenUrl'],
      cantidad: map['cantidad'] ?? 1,
    );
  }
}
