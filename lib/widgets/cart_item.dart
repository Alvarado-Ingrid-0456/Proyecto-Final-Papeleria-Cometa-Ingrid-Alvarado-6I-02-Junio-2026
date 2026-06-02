
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  const CartItem({
    super.key,
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
  });

  void _confirmDelete(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text('Eliminar producto'),
          ],
        ),
        content: Text(
          '¿Quieres eliminar "$title" del carrito?',
          style: const TextStyle(fontSize: 15),
        ),
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
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              cartProvider.removeItem(productId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        _confirmDelete(context, cartProvider);
        return false; // El diálogo maneja la eliminación
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text('Eliminar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withValues(alpha: 0.07),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 14),

              // Title & price info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${price.toStringAsFixed(2)} c/u',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtotal
                    Text(
                      'Subtotal: \$${(price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Quantity controls column
              Column(
                children: [
                  // Delete button
                  IconButton(
                    onPressed: () => _confirmDelete(context, cartProvider),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    tooltip: 'Eliminar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),

                  // Quantity row: - [n] +
                  Container(
                    decoration: BoxDecoration(
                      color: primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrement
                        _QuantityButton(
                          icon: Icons.remove,
                          color: primaryPurple,
                          onTap: () => cartProvider.removeSingleItem(productId),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                        // Increment
                        _QuantityButton(
                          icon: Icons.add,
                          color: primaryPurple,
                          onTap: () => cartProvider.addItem(
                            productId: productId,
                            price: price,
                            title: title,
                            imageUrl: imageUrl,
                            quantity: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFB000FF), size: 36),
    );
  }
}

/// Botón pequeño circular para incrementar/decrementar
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
