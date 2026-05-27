class CategoryModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String? imagenUrl;

  CategoryModel({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.imagenUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagenUrl: map['imagenUrl'],
    );
  }
}
