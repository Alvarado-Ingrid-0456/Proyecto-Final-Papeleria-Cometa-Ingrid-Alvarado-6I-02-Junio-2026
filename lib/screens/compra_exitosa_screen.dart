import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart'; // Ensure CartProvider is imported

class CompraExitosaScreen extends StatelessWidget {
  const CompraExitosaScreen({super.key}); // Use super.key

  @override
  Widget build(BuildContext context) {
    // Access CartProvider to get total amount, or pass it as an argument if preferred
    final cartProvider = Provider.of<CartProvider>(context);
    // Use totalAmount from CartProvider, assuming it's correctly calculated
    final double totalAmount = cartProvider.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra Exitosa'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Optional: disable back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green[700],
              ),
              const SizedBox(height: 25),
              const Text(
                '¡Gracias por tu compra!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Tu pedido ha sido procesado exitosamente.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Total pagado: \$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the home screen after purchase
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child:
                    const Text('Ir al Inicio', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to the catalog screen
                  Navigator.of(context).pushReplacementNamed('/catalog');
                },
                child: const Text('Ver más productos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
