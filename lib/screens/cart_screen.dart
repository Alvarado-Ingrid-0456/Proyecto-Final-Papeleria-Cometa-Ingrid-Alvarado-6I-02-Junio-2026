
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
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        centerTitle: true,
      ),
      drawer: const AppNavigationDrawer(),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: cart.itemCount > 0
                        ? () {
                            Navigator.of(context).pushNamed('/payment');
                          }
                        : null,
                    child: const Text('PAGAR AHORA'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.itemCount == 0
                ? const Center(
                    child: Text(
                      'Tu carrito está vacío.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
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
        ],
      ),
    );
  }
}
