
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/providers/auth_provider.dart';

class PagarCompraScreen extends StatefulWidget {
  const PagarCompraScreen({super.key});

  @override
  State<PagarCompraScreen> createState() => _PagarCompraScreenState();
}

class _PagarCompraScreenState extends State<PagarCompraScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cardController;
  late TextEditingController _dateController;
  late TextEditingController _cvvController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = authProvider.usuarioDatos;

    _nameController = TextEditingController(text: profile?.nombre ?? '');
    _addressController = TextEditingController(text: profile?.direccion ?? '');
    _cardController = TextEditingController();
    _dateController = TextEditingController();
    _cvvController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cardController.dispose();
    _dateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final cartItems = cartProvider.items.values.toList();
    final totalAmount = cartProvider.totalAmount;

    try {
      // 1. Guardar la compra en la base de datos
      await FirebaseFirestore.instance.collection('compras').add({
        'usuario': _nameController.text.trim(),
        'total': totalAmount,
        'fecha': DateTime.now().toIso8601String().substring(0, 10),
        'items': cartItems.map((item) => {
          'productId': item.productId,
          'title': item.title,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        'direccion': _addressController.text.trim(),
        'fechaCompra': Timestamp.now(),
      });

      // 2. Reducir el stock de cada producto comprado
      for (var item in cartItems) {
        final prodId = item.productId;

        // Omitir productos de prueba/impresión virtuales que no existen en Firestore
        if (prodId.startsWith('p_mock') ||
            prodId.startsWith('nb') ||
            prodId.startsWith('s') ||
            prodId.startsWith('a') ||
            prodId.startsWith('c') ||
            prodId.startsWith('g') ||
            prodId.startsWith('print_')) {
          continue;
        }

        final prodRef = FirebaseFirestore.instance.collection('productos').doc(prodId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(prodRef);
          if (snapshot.exists) {
            final currentStock = snapshot.data()?['stock'] ?? 0;
            final newStock = (currentStock - item.quantity).clamp(0, 999999);
            transaction.update(prodRef, {'stock': newStock});
          }
        });
      }

      // 3. Vaciar el carrito
      cartProvider.clear();

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed('/order-success');
      }
    } catch (e) {
      debugPrint("Error al procesar el pedido: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al procesar la compra: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagar Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Por favor ingresa tu nombre.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección de Envío', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Por favor ingresa tu dirección.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardController,
                decoration: const InputDecoration(labelText: 'Número de Tarjeta', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Por favor ingresa tu número de tarjeta.' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'MM/AA', border: OutlineInputBorder()),
                      keyboardType: TextInputType.datetime,
                      validator: (value) => value!.isEmpty ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submitOrder,
                  child: const Text('Confirmar Pedido'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
