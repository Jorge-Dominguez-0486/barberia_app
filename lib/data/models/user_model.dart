class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String? fotoUrl;
  final bool isAdmin;
  final DateTime fechaCreacion;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono = '',
    this.fotoUrl,
    this.isAdmin = false,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'isAdmin': isAdmin,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      fotoUrl: map['fotoUrl'],
      isAdmin: map['isAdmin'] ?? false,
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }
}
