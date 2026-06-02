import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String categoriaId;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String imagenUrl;
  final bool activo;
  final DateTime fechaCreacion;

  Producto({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imagenUrl,
    required this.activo,
    required this.fechaCreacion,
  });

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,
      categoriaId: data['categoriaId'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      imagenUrl: data['imagenUrl'] ?? '',
      activo: data['activo'] ?? true,
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoriaId': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagenUrl': imagenUrl,
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}
