import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String direccion;
  final String rol;
  final DateTime fechaRegistro;
  final bool activo;
  final String imagenUrl;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.rol,
    required this.fechaRegistro,
    required this.activo,
    this.imagenUrl = '',
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      direccion: data['direccion'] ?? '',
      rol: data['rol'] ?? 'cliente',
      fechaRegistro:
          (data['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activo: data['activo'] ?? true,
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'rol': rol,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'activo': activo,
      'imagenUrl': imagenUrl,
    };
  }

  bool get isAdmin => rol == 'administrador';
}
