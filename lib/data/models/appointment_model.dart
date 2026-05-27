class AppointmentModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String serviceId;
  final String serviceNombre;
  final DateTime fecha;
  final String hora;
  final String estado;
  final String notas;

  AppointmentModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.serviceId,
    required this.serviceNombre,
    required this.fecha,
    required this.hora,
    this.estado = 'pendiente',
    this.notas = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'serviceId': serviceId,
      'serviceNombre': serviceNombre,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'estado': estado,
      'notas': notas,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceNombre: map['serviceNombre'] ?? '',
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
      hora: map['hora'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      notas: map['notas'] ?? '',
    );
  }
}
