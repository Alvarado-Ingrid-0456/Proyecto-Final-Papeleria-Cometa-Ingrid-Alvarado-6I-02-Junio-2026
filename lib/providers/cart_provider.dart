
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single item entry within the shopping cart
class CartItem {
  final String id; // Unique identifier for this cart entry
  final String productId; // Reference to the product's ID
  final String title;
  final int quantity; // Number of this item in the cart
  final double price; // Price per unit of the item
  final String imageUrl; // URL of the product's image

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl = '', // Default to empty string if no image URL is provided
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

// Manages the state of the shopping cart
class CartProvider with ChangeNotifier {
  // Use a Map to store CartItem objects, keyed by productId for easy access and updates
  Map<String, CartItem> _items = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CartProvider() {
    // Listen to authentication changes to load cart
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadCartFromFirestore(user.uid);
      } else {
        _items = {};
        notifyListeners();
      }
    });
  }

  Future<void> _loadCartFromFirestore(String uid) async {
    try {
      final doc = await _db.collection('carritos').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['items'] != null) {
          final Map<String, CartItem> loadedItems = {};
          (data['items'] as Map<String, dynamic>).forEach((key, value) {
            loadedItems[key] = CartItem.fromMap(Map<String, dynamic>.from(value));
          });
          _items = loadedItems;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error loading cart from Firestore: $e");
    }
  }

  Future<void> _saveCartToFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final Map<String, Map<String, dynamic>> serializedItems = {};
      _items.forEach((key, item) {
        serializedItems[key] = item.toMap();
      });
      await _db.collection('carritos').doc(uid).set({'items': serializedItems});
    } catch (e) {
      debugPrint("Error saving cart to Firestore: $e");
    }
  }

  // Getter to return a copy of the current cart items
  Map<String, CartItem> get items {
    return {..._items}; // Return a copy to prevent external modifications
  }

  // Getter for the count of unique item types in the cart
  int get itemCount {
    return _items.length;
  }

  // Getter to calculate the total cost of all items in the cart
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      // Sum up the price multiplied by quantity for each item
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Method to add an item to the cart
  void addItem({
    required String productId,
    required double price,
    required String title,
    String imageUrl = '',
    int quantity = 1,
  }) {
    if (_items.containsKey(productId)) {
      // If the product is already in the cart, increment its quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + quantity, // Increment quantity by the requested amount
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl, // Maintain existing image URL
        ),
      );
    } else {
      // If it's a new product, add it to the cart with the requested quantity
      _items.putIfAbsent(
        productId,
        () => CartItem(
          // Generate a unique ID for this cart entry (e.g., timestamp + productId)
          id: '${DateTime.now().toIso8601String()}_$productId',
          productId: productId,
          title: title,
          quantity: quantity,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners(); // Notify listeners about the state change
    _saveCartToFirestore();
  }

  // Method to remove an item completely from the cart using its productId
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    _saveCartToFirestore();
  }

  // Method to decrease the quantity of an item by one, or remove if quantity becomes 0
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return; // Exit if the item is not in the cart
    }
    final existingItem = _items[productId]!;
    if (existingItem.quantity > 1) {
      // If quantity is greater than 1, decrement it
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          productId: value.productId,
          title: value.title,
          quantity: value.quantity - 1,
          price: value.price,
          imageUrl: value.imageUrl,
        ),
      );
    } else {
      // If quantity is 1, remove the item entirely from the cart
      _items.remove(productId);
    }
    notifyListeners();
    _saveCartToFirestore();
  }

  // Method to clear all items from the cart
  void clear() {
    _items = {}; // Reset the items map to empty
    notifyListeners();
    _saveCartToFirestore();
  }
}
