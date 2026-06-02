import 'package:flutter/material.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key}); // Use super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '¡Tu carrito está vacío!',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
      // Removed the extra positional argument.
      // Navigation to cart is now handled by the AppBar icon in other screens.
    );
  }
}
