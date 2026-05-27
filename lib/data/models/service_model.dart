class ServiceModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionMinutos;
  final String? imagenUrl;
  final bool activo;

  ServiceModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracionMinutos,
    this.imagenUrl,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'duracionMinutos': duracionMinutos,
      'imagenUrl': imagenUrl,
      'activo': activo,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      duracionMinutos: map['duracionMinutos'] ?? 30,
      imagenUrl: map['imagenUrl'],
      activo: map['activo'] ?? true,
    );
  }
}
