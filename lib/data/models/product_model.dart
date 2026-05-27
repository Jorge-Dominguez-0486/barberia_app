class ProductModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  final String categoriaId;
  final int stock;
  final bool activo;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoriaId,
    this.imagenUrl,
    this.stock = 0,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoriaId': categoriaId,
      'stock': stock,
      'activo': activo,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      categoriaId: map['categoriaId'] ?? '',
      imagenUrl: map['imagenUrl'],
      stock: map['stock'] ?? 0,
      activo: map['activo'] ?? true,
    );
  }
}
