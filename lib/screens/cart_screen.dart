
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart' show CartProvider;
import 'package:myapp/widgets/cart_item.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6FF),
      appBar: AppBar(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Tu Carrito',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vaciar carrito',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('¿Vaciar carrito?'),
                    content: const Text('Se eliminarán todos los productos del carrito.'),
                    actions: [
                      TextButton(
                        child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Vaciar'),
                        onPressed: () {
                          cart.clear();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: cart.itemCount == 0
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // List of items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    itemCount: cart.itemCount,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return CartItem(
                        id: cartItem.id,
                        productId: cartItem.productId,
                        title: cartItem.title,
                        quantity: cartItem.quantity,
                        price: cartItem.price,
                        imageUrl: cartItem.imageUrl,
                      );
                    },
                  ),
                ),

                // Summary card at bottom
                _buildSummaryCard(context, cart, primaryPurple),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: primaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: primaryPurple,
              size: 72,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Agrega productos desde el catálogo',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/catalog'),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Ver Catálogo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, CartProvider cart, Color primaryPurple) {
    final totalItems = cart.items.values.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Items count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productos ($totalItems ${totalItems == 1 ? 'artículo' : 'artículos'}):',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)} MXN',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB000FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pay button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/payment'),
              icon: const Icon(Icons.payment_outlined),
              label: const Text(
                'PAGAR AHORA',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
