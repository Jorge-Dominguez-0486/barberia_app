import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestore() async {
  final firestore = FirebaseFirestore.instance;

  final categories = [
    {'nombre': 'Cortes', 'descripcion': 'Estilos de corte de cabello', 'imagenUrl': ''},
    {'nombre': 'Barba', 'descripcion': 'Arreglo y diseño de barba', 'imagenUrl': ''},
    {'nombre': 'Tratamientos', 'descripcion': 'Tratamientos capilares', 'imagenUrl': ''},
  ];

  final services = [
    {'nombre': 'Corte clásico', 'descripcion': 'Corte de cabello tradicional con tijera y máquina', 'precio': 150.0, 'duracion': 30, 'imagenUrl': '', 'activo': true},
    {'nombre': 'Corte + Barba', 'descripcion': 'Corte de cabello más arreglo completo de barba', 'precio': 200.0, 'duracion': 45, 'imagenUrl': '', 'activo': true},
    {'nombre': 'Afeitado navaja', 'descripcion': 'Afeitado clásico con navaja y toalla caliente', 'precio': 120.0, 'duracion': 25, 'imagenUrl': '', 'activo': true},
    {'nombre': 'Tratamiento capilar', 'descripcion': 'Tratamiento revitalizante para el cabello', 'precio': 180.0, 'duracion': 40, 'imagenUrl': '', 'activo': true},
    {'nombre': 'Diseño de barba', 'descripcion': 'Diseño y perfilado profesional de barba', 'precio': 100.0, 'duracion': 20, 'imagenUrl': '', 'activo': true},
  ];

  final products = [
    {'nombre': 'Pomada para cabello', 'descripcion': 'Pomada de fijación fuerte con acabado mate', 'precio': 250.0, 'imagenUrl': '', 'categoriaId': '', 'activo': true},
    {'nombre': 'Aceite para barba', 'descripcion': 'Aceite hidratante con aroma a madera', 'precio': 180.0, 'imagenUrl': '', 'categoriaId': '', 'activo': true},
    {'nombre': 'Shampoo anticaspa', 'descripcion': 'Shampoo especial para control de caspa', 'precio': 120.0, 'imagenUrl': '', 'categoriaId': '', 'activo': true},
    {'nombre': 'Cera modeladora', 'descripcion': 'Cera de moldeado flexible con brillo natural', 'precio': 200.0, 'imagenUrl': '', 'categoriaId': '', 'activo': true},
  ];

  for (final cat in categories) {
    await firestore.collection('categories').add(cat);
  }

  for (final svc in services) {
    await firestore.collection('services').add(svc);
  }

  for (final prod in products) {
    await firestore.collection('products').add(prod);
  }
}
