
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.stock = 100,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? data['nombre'] ?? '',
      description: data['description'] ?? data['descripcion'] ?? '',
      price: (data['price'] ?? data['precio'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? data['imagenUrl'] ?? '',
      stock: data['stock'] ?? 100,
    );
  }
}
