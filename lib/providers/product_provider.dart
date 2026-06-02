import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Product> get items {
    return [..._items];
  }

  ProductProvider() {
    _initRealtimeProducts();
  }

  void _initRealtimeProducts() {
    _isLoading = true;
    FirebaseFirestore.instance
        .collection('productos')
        .snapshots()
        .listen((snapshot) {
      final List<Product> loadedProducts = [];
      for (var doc in snapshot.docs) {
        loadedProducts.add(Product.fromFirestore(doc));
      }
      if (loadedProducts.isNotEmpty) {
        _items = loadedProducts;
      } else {
        _items = _getMockProducts();
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Failed to subscribe to products: $e");
      _items = _getMockProducts();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchAndSetProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('productos')
          .get()
          .timeout(const Duration(seconds: 10));
      final List<Product> loadedProducts = [];
      for (var doc in snapshot.docs) {
        loadedProducts.add(Product.fromFirestore(doc));
      }
      if (loadedProducts.isNotEmpty) {
        _items = loadedProducts;
      } else {
        debugPrint("Firestore productos collection is empty, loading mock products.");
        _items = _getMockProducts();
      }
    } catch (e) {
      debugPrint("Failed to fetch products from Firestore: $e");
      _items = _getMockProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: 'p1',
        title: 'Camisa Elegante',
        description: 'Una camisa de alta calidad para ocasiones especiales.',
        price: 49.99,
        imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Shirt',
      ),
      Product(
        id: 'p2',
        title: 'Pantalón Vaquero',
        description: 'Pantalón vaquero clásico y cómodo.',
        price: 35.50,
        imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Pants',
      ),
      Product(
        id: 'p3',
        title: 'Zapatos Deportivos',
        description: 'Zapatos perfectos para correr o entrenar.',
        price: 75.00,
        imageUrl: 'https://via.placeholder.com/150/00FF00/FFFFFF?text=Shoes',
      ),
      Product(
        id: 'p4',
        title: 'Chaqueta de Cuero',
        description: 'Chaqueta moderna y resistente.',
        price: 120.00,
        imageUrl: 'https://via.placeholder.com/150/FFFF00/000000?text=Jacket',
      ),
    ];
  }

  Product? findById(String id) {
    try {
      return _items.firstWhere((prod) => prod.id == id);
    } catch (e) {
      return null;
    }
  }

  void addProduct() {
    // TODO: Implement add product logic
    notifyListeners();
  }
}
