import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class MisPedidosScreen extends StatelessWidget {
  static const routeName = '/mis-pedidos';

  const MisPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    const backgroundColor = Color(0xFFF5E6FF);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    final currentUserEmail = authProvider.user?.email;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        centerTitle: true,
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      drawer: const AppNavigationDrawer(),
      body: currentUserId == null
          ? const Center(child: Text('Debes iniciar sesión para ver tus pedidos.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('compras')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryPurple));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final userDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final docUserId = data['userId'];
                  final docEmail = data['email'];
                  final docUsuario = data['usuario'];
                  final profileName = authProvider.usuarioDatos?.nombre;

                  return (docUserId != null && docUserId == currentUserId) ||
                         (docEmail != null && docEmail == currentUserEmail) ||
                         (profileName != null && docUsuario == profileName);
                }).toList();

                if (userDocs.isEmpty) {
                  return _buildEmptyState();
                }

                // Sort locally by date or ID (most recent first)
                userDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final timestampA = dataA['fechaCompra'] as Timestamp?;
                  final timestampB = dataB['fechaCompra'] as Timestamp?;
                  if (timestampA != null && timestampB != null) {
                    return timestampB.compareTo(timestampA); // Descending
                  }
                  final String dateA = dataA['fecha'] ?? '';
                  final String dateB = dataB['fecha'] ?? '';
                  return dateB.compareTo(dateA);
                });

                return _buildOrdersList(userDocs, context);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.purple.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes pedidos registrados.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> docs, BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final String docId = doc.id;
        final double total = (data['total'] ?? 0.0).toDouble();
        final String fecha = data['fecha'] ?? '';
        final String direccion = data['direccion'] ?? 'Recoger en sucursal';
        final List<dynamic> items = data['items'] ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: ExpansionTile(
            title: Text(
              'Pedido: #${docId.length > 6 ? docId.substring(0, 6).toUpperCase() : docId.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple),
            ),
            subtitle: Text('Fecha: $fecha - Total: \$${total.toStringAsFixed(2)}'),
            leading: const Icon(Icons.receipt_long, color: primaryPurple, size: 30),
            childrenPadding: const EdgeInsets.all(16.0),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dirección de entrega: $direccion', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Divider(),
              const Text('Artículos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...items.map((item) {
                final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
                final String title = itemMap['title'] ?? 'Artículo';
                final int quantity = itemMap['quantity'] ?? 1;
                final double price = (itemMap['price'] ?? 0.0).toDouble();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$title (x$quantity)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '\$${(price * quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
