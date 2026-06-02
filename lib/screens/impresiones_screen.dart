import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class ImpresionesScreen extends StatefulWidget {
  const ImpresionesScreen({super.key});

  @override
  State<ImpresionesScreen> createState() => _ImpresionesScreenState();
}

class _ImpresionesScreenState extends State<ImpresionesScreen> {
  String? _selectedFileType;
  String? _selectedPaymentMethod;
  String? _selectedDeliveryMethod;
  int _quantity = 1;
  String? _fileName;
  double _fileSizeMB = 0.0;

  final List<String> _fileTypes = [
    'Documento PDF (.pdf)',
    'Documento Word (.docx / .doc)',
    'Imagen (PNG / JPG)',
    'Presentación PowerPoint (.pptx)',
  ];

  final List<String> _paymentMethods = [
    'Efectivo en sucursal',
    'Tarjeta de Crédito / Débito',
    'Transferencia Bancaria',
  ];

  final List<String> _deliveryMethods = [
    'Recoger en sucursal',
    'Envío a domicilio',
  ];

  // Helper to get prices based on file type
  double _getPricePerSheet() {
    if (_selectedFileType == null) return 2.00;
    if (_selectedFileType!.contains('.pdf')) return 1.50;
    if (_selectedFileType!.contains('.docx')) return 2.00;
    if (_selectedFileType!.contains('Imagen')) return 5.00; // Photos are pricier
    return 3.00;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Simulates opening a file picker by showing a beautiful custom dialog
  void _simulateFilePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<Map<String, dynamic>> simulatedFiles = [
          {'name': 'resumen_historia.pdf', 'size': 1.4, 'icon': Icons.picture_as_pdf, 'color': Colors.red},
          {'name': 'proyecto_final_computacion.docx', 'size': 3.2, 'icon': Icons.description, 'color': Colors.blue},
          {'name': 'captura_grafica_arte.png', 'size': 0.8, 'icon': Icons.image, 'color': Colors.green},
          {'name': 'presentacion_cometa.pptx', 'size': 5.5, 'icon': Icons.slideshow, 'color': Colors.orange},
        ];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Selecciona un archivo de tu dispositivo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFB000FF),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: simulatedFiles.map((file) {
              return ListTile(
                leading: Icon(file['icon'] as IconData, color: file['color'] as Color, size: 32),
                title: Text(file['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${file['size']} MB'),
                onTap: () {
                  Navigator.of(context).pop(file);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFFB000FF))),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _fileName = result['name'] as String;
          _fileSizeMB = result['size'] as double;
          // Auto-select matching file type if appropriate
          if (_fileName!.endsWith('.pdf')) {
            _selectedFileType = _fileTypes[0];
          } else if (_fileName!.endsWith('.docx')) {
            _selectedFileType = _fileTypes[1];
          } else if (_fileName!.endsWith('.png') || _fileName!.endsWith('.jpg')) {
            _selectedFileType = _fileTypes[2];
          } else if (_fileName!.endsWith('.pptx')) {
            _selectedFileType = _fileTypes[3];
          }
        });
      }
    });
  }

  void _submitForm() {
    if (_fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un archivo para imprimir.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedFileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona el tipo de archivo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona el método de pago.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedDeliveryMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona el método de entrega.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double pricePerSheet = _getPricePerSheet();
    final double totalPrice = pricePerSheet * _quantity;

    // Add to cart provider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      productId: 'print_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Impresión: $_fileName ($_quantity págs)',
      price: totalPrice,
      // Pass a custom icon/image or placeholder representing printing
      imageUrl: 'https://via.placeholder.com/150/00A2FF/FFFFFF?text=Impresion',
    );

    // Show confirmation dialog or bottomsheet
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('¡Pedido Listo!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu servicio de impresión se ha añadido al carrito.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Archivo: $_fileName', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Cantidad de páginas/copias: $_quantity'),
            Text('Precio unitario: \$${pricePerSheet.toStringAsFixed(2)}'),
            Text('Total estimado: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB000FF))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/home'); // Go back to Home
            },
            child: const Text('Seguir Comprando', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/cart'); // Go to Cart
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB000FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ver Carrito'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    const backgroundColor = Color(0xFFF5E6FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'PAPELERÍA COMETA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: const AppNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen Title
            const Center(
              child: Text(
                'IMPRESIONES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryPurple,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upload File Box
            GestureDetector(
              onTap: _simulateFilePicker,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.05),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD0E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.file_upload_outlined,
                        color: Color(0xFF00A2FF),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fileName ?? 'Subir archivos',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fileName != null
                          ? 'Tamaño: ${_fileSizeMB.toStringAsFixed(1)} MB'
                          : 'Toca para seleccionar un archivo',
                      style: const TextStyle(
                        fontSize: 14,
                        color: primaryPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Type Dropdown
            _buildLabel('Tipo de archivo'),
            _buildDropdown(
              value: _selectedFileType,
              items: _fileTypes,
              hint: 'Seleccionar',
              onChanged: (val) {
                setState(() {
                  _selectedFileType = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Quantity Control
            _buildLabel('Cantidad'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.05),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decrement Button
                  IconButton(
                    onPressed: _decrement,
                    icon: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: primaryPurple,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                  // Quantity
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                  // Increment Button
                  IconButton(
                    onPressed: _increment,
                    icon: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: primaryPurple,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Pricing Card (Real-time price visibility)
            _buildLabel('Resumen de Precios'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.05),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: primaryPurple.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Unit Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.sell_outlined, color: primaryPurple, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Precio por Unidad:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${_getPricePerSheet().toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),
                  // Estimated Total Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calculate_outlined, color: primaryPurple, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Total Estimado:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${(_getPricePerSheet() * _quantity).toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Table showing all prices at a glance
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryPurple.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Precios de referencia por unidad (Pág.):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PDF: \$1.50',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedFileType?.contains('.pdf') == true
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedFileType?.contains('.pdf') == true
                                    ? primaryPurple
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'Word: \$2.00',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedFileType?.contains('.docx') == true
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedFileType?.contains('.docx') == true
                                    ? primaryPurple
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'Imagen: \$5.00',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedFileType?.contains('Imagen') == true
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedFileType?.contains('Imagen') == true
                                    ? primaryPurple
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'Otros: \$3.00',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedFileType != null &&
                                        !_selectedFileType!.contains('.pdf') &&
                                        !_selectedFileType!.contains('.docx') &&
                                        !_selectedFileType!.contains('Imagen')
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedFileType != null &&
                                        !_selectedFileType!.contains('.pdf') &&
                                        !_selectedFileType!.contains('.docx') &&
                                        !_selectedFileType!.contains('Imagen')
                                    ? primaryPurple
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Method Dropdown
            _buildLabel('Seleccione método de pago'),
            _buildDropdown(
              value: _selectedPaymentMethod,
              items: _paymentMethods,
              hint: 'Seleccionar',
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Delivery Method Dropdown
            _buildLabel('Seleccione método de entrega'),
            _buildDropdown(
              value: _selectedDeliveryMethod,
              items: _deliveryMethods,
              hint: 'Seleccionar',
              onChanged: (val) {
                setState(() {
                  _selectedDeliveryMethod = val;
                });
              },
            ),
            const SizedBox(height: 32),

            // Continue Button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        labelText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFB000FF),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.05),
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xFFB000FF), fontSize: 16),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB000FF), size: 30),
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFFB000FF), fontSize: 16, fontWeight: FontWeight.w600),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
