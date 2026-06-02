import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class AdminTablesScreen extends StatefulWidget {
  const AdminTablesScreen({super.key});

  @override
  State<AdminTablesScreen> createState() => _AdminTablesScreenState();
}

class _AdminTablesScreenState extends State<AdminTablesScreen> {
  String _activeTab = 'Productos'; // Default active tab

  // Mock fallbacks if Firestore collections are empty or fail
  final List<Map<String, dynamic>> _mockProducts = [
    {'id': 'p_mock1', 'nombre': 'Lápiz HB', 'precio': 5.0, 'stock': 150, 'category': 'Útiles'},
    {'id': 'p_mock2', 'nombre': 'Cuaderno 100 hojas', 'precio': 25.0, 'stock': 80, 'category': 'Libretas'},
    {'id': 'p_mock3', 'nombre': 'Marcadores x12', 'precio': 55.0, 'stock': 45, 'category': 'Arte'},
    {'id': 'p_mock4', 'nombre': 'Tijeras escolares', 'precio': 25.0, 'stock': 60, 'category': 'Manualidades'},
  ];

  final List<Map<String, dynamic>> _mockUsers = [
    {'id': 'u_mock1', 'nombre': 'Admin123', 'email': 'admin@cometa.com', 'rol': 'administrador'},
    {'id': 'u_mock2', 'nombre': 'Juan Pérez', 'email': 'juan.perez@gmail.com', 'rol': 'cliente'},
    {'id': 'u_mock3', 'nombre': 'María López', 'email': 'maria.lopez@gmail.com', 'rol': 'cliente'},
    {'id': 'u_mock4', 'nombre': 'Pedro Gómez', 'email': 'pedro.gomez@gmail.com', 'rol': 'cliente'},
  ];

  final List<Map<String, dynamic>> _mockPurchases = [
    {'id': 'c_mock1', 'usuario': 'Juan Pérez', 'total': 120.0, 'fecha': '2026-06-01'},
    {'id': 'c_mock2', 'usuario': 'María López', 'total': 310.0, 'fecha': '2026-06-01'},
    {'id': 'c_mock3', 'usuario': 'Pedro Gómez', 'total': 55.0, 'fecha': '2026-06-02'},
    {'id': 'c_mock4', 'usuario': 'Juan Pérez', 'total': 25.0, 'fecha': '2026-06-02'},
  ];

  final List<String> _categoriesList = [
    'Impresiones',
    'Útiles',
    'Libretas',
    'Arte',
    'Manualidades',
    'Regalos'
  ];

  // Helper to safely format IDs for the table display (keeps it short)
  String _formatId(String id) {
    if (id.length > 8) {
      return id.substring(0, 8);
    }
    return id;
  }

  // --- CRUD Operations Dialogs ---

  // 1. ADD RECORD DIALOG
  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final val1Controller = TextEditingController();
    final val2Controller = TextEditingController();
    final val3Controller = TextEditingController();
    final val4Controller = TextEditingController(); // For image URL
    final val5Controller = TextEditingController(); // For description
    String selectedRole = 'cliente';
    String selectedCategory = 'Útiles';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Agregar $_activeTab',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB000FF)),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeTab == 'Productos') ...[
                        TextFormField(
                          controller: val1Controller,
                          decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: val2Controller,
                          decoration: const InputDecoration(labelText: 'Precio (\$)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Número válido' : null,
                        ),
                        TextFormField(
                          controller: val3Controller,
                          decoration: const InputDecoration(labelText: 'Stock / Inventario'),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Entero válido' : null,
                        ),
                        TextFormField(
                          controller: val4Controller,
                          decoration: const InputDecoration(labelText: 'URL de Imagen (Opcional)'),
                        ),
                        TextFormField(
                          controller: val5Controller,
                          decoration: const InputDecoration(labelText: 'Descripción'),
                          maxLines: 2,
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        // Dropdown for Category
                        InputDecorator(
                          decoration: const InputDecoration(labelText: 'Categoría'),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: _categoriesList.map((cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat));
                              }).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedCategory = val ?? 'Útiles';
                                });
                              },
                            ),
                          ),
                        ),
                      ] else if (_activeTab == 'Usuarios') ...[
                        TextFormField(
                          controller: val1Controller,
                          decoration: const InputDecoration(labelText: 'Nombre completo'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: val2Controller,
                          decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || !v.contains('@') ? 'Email válido' : null,
                        ),
                        const SizedBox(height: 12),
                        // Dropdown for User Role without value deprecation
                        InputDecorator(
                          decoration: const InputDecoration(labelText: 'Rol de Usuario'),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                                DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                              ],
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedRole = val ?? 'cliente';
                                });
                              },
                            ),
                          ),
                        ),
                      ] else if (_activeTab == 'Pedidos') ...[
                        TextFormField(
                          controller: val1Controller,
                          decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: val2Controller,
                          decoration: const InputDecoration(labelText: 'Total de la Compra (\$)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Número válido' : null,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.of(ctx).pop();

                    try {
                      if (_activeTab == 'Productos') {
                        final String imgUrl = val4Controller.text.trim().isEmpty 
                            ? 'https://picsum.photos/seed/newproduct/200/300'
                            : val4Controller.text.trim();

                        await FirebaseFirestore.instance.collection('productos').add({
                          'title': val1Controller.text,
                          'price': double.parse(val2Controller.text),
                          'stock': int.parse(val3Controller.text),
                          'imageUrl': imgUrl,
                          'description': val5Controller.text,
                          'category': selectedCategory,
                          'categoria': selectedCategory,
                        });
                      } else if (_activeTab == 'Usuarios') {
                        await FirebaseFirestore.instance.collection('usuarios').add({
                          'nombre': val1Controller.text,
                          'email': val2Controller.text,
                          'rol': selectedRole,
                          'activo': true,
                          'fechaRegistro': Timestamp.now(),
                        });
                      } else if (_activeTab == 'Pedidos') {
                        await FirebaseFirestore.instance.collection('compras').add({
                          'usuario': val1Controller.text,
                          'total': double.parse(val2Controller.text),
                          'fecha': DateTime.now().toIso8601String().substring(0, 10),
                        });
                      }
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('¡$_activeTab agregado exitosamente!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB000FF), foregroundColor: Colors.white),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 2. EDIT RECORD DIALOG
  void _showEditDialog(String docId, Map<String, dynamic> currentData) {
    final formKey = GlobalKey<FormState>();
    final val1Controller = TextEditingController();
    final val2Controller = TextEditingController();
    final val3Controller = TextEditingController();
    final val4Controller = TextEditingController(); // For image URL
    final val5Controller = TextEditingController(); // For description
    String selectedRole = 'cliente';
    String selectedCategory = 'Útiles';

    // Pre-populate values
    if (_activeTab == 'Productos') {
      val1Controller.text = currentData['title'] ?? currentData['nombre'] ?? '';
      val2Controller.text = (currentData['price'] ?? currentData['precio'] ?? 0.0).toString();
      val3Controller.text = (currentData['stock'] ?? 100).toString();
      val4Controller.text = currentData['imageUrl'] ?? '';
      val5Controller.text = currentData['description'] ?? '';
      selectedCategory = currentData['category'] ?? currentData['categoria'] ?? 'Útiles';
      if (!_categoriesList.contains(selectedCategory)) {
        selectedCategory = 'Útiles';
      }
    } else if (_activeTab == 'Usuarios') {
      val1Controller.text = currentData['nombre'] ?? '';
      val2Controller.text = currentData['email'] ?? '';
      selectedRole = currentData['rol'] ?? 'cliente';
    } else if (_activeTab == 'Pedidos') {
      val1Controller.text = currentData['usuario'] ?? '';
      val2Controller.text = (currentData['total'] ?? 0.0).toString();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Editar $_activeTab',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB000FF)),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeTab == 'Productos') ...[
                        TextFormField(
                          controller: val1Controller,
                          decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: val2Controller,
                          decoration: const InputDecoration(labelText: 'Precio (\$)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Número válido' : null,
                        ),
                        TextFormField(
                          controller: val3Controller,
                          decoration: const InputDecoration(labelText: 'Stock / Inventario'),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Entero válido' : null,
                        ),
                        TextFormField(
                          controller: val4Controller,
                          decoration: const InputDecoration(labelText: 'URL de Imagen (Opcional)'),
                        ),
                        TextFormField(
                          controller: val5Controller,
                          decoration: const InputDecoration(labelText: 'Descripción'),
                          maxLines: 2,
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: const InputDecoration(labelText: 'Categoría'),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: _categoriesList.map((cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat));
                              }).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedCategory = val ?? 'Útiles';
                                });
                              },
                            ),
                          ),
                        ),
                      ] else if (_activeTab == 'Usuarios') ...[
                        TextFormField(
                          controller: val1Controller,
                          decoration: const InputDecoration(labelText: 'Nombre completo'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: val2Controller,
                          decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || !v.contains('@') ? 'Email válido' : null,
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: const InputDecoration(labelText: 'Rol de Usuario'),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                                DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                              ],
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedRole = val ?? 'cliente';
                                });
                              },
                            ),
                          ),
                        ),
                      ] else if (_activeTab == 'Pedidos') ...[
                        TextFormField(
                          controller: val1Controller,
                          decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: val2Controller,
                          decoration: const InputDecoration(labelText: 'Total de la Compra (\$)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Número válido' : null,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.of(ctx).pop();

                    // For mock records, update locally or show feedback
                    if (docId.startsWith('p_mock') || docId.startsWith('u_mock') || docId.startsWith('c_mock')) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Los registros de prueba locales no pueden modificarse en Firestore.'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    try {
                      if (_activeTab == 'Productos') {
                        final String imgUrl = val4Controller.text.trim().isEmpty 
                            ? 'https://picsum.photos/seed/newproduct/200/300'
                            : val4Controller.text.trim();

                        await FirebaseFirestore.instance.collection('productos').doc(docId).update({
                          'title': val1Controller.text,
                          'price': double.parse(val2Controller.text),
                          'stock': int.parse(val3Controller.text),
                          'imageUrl': imgUrl,
                          'description': val5Controller.text,
                          'category': selectedCategory,
                          'categoria': selectedCategory,
                        });
                      } else if (_activeTab == 'Usuarios') {
                        await FirebaseFirestore.instance.collection('usuarios').doc(docId).update({
                          'nombre': val1Controller.text,
                          'email': val2Controller.text,
                          'rol': selectedRole,
                        });
                      } else if (_activeTab == 'Pedidos') {
                        await FirebaseFirestore.instance.collection('compras').doc(docId).update({
                          'usuario': val1Controller.text,
                          'total': double.parse(val2Controller.text),
                        });
                      }
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('¡$_activeTab actualizado exitosamente!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB000FF), foregroundColor: Colors.white),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 3. DELETE RECORD CONFIRMATION
  void _showDeleteConfirm(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirmar Eliminación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text('¿Estás seguro de que deseas eliminar "$name"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();

                if (docId.startsWith('p_mock') || docId.startsWith('u_mock') || docId.startsWith('c_mock')) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Los registros de prueba locales no pueden eliminarse de Firestore.'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  String collection = _activeTab == 'Productos'
                      ? 'productos'
                      : _activeTab == 'Usuarios'
                          ? 'usuarios'
                          : 'compras';

                  await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('¡$name eliminado exitosamente!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Screen Title
          const Center(
            child: Text(
              'Tablas Administrativas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Horizontal Navigation Tabs Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton('Productos'),
                _buildTabButton('Usuarios'),
                _buildTabButton('Pedidos'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic Table Card Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.05),
                      blurRadius: 12.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Solid Purple Card Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      color: primaryPurple,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _activeTab,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // "+ Agregar" Button
                          ElevatedButton.icon(
                            onPressed: _showAddDialog,
                            icon: const Icon(Icons.add, size: 16, color: primaryPurple),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryPurple,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Table Display (Connected to Firestore with Fallbacks)
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection(
                          _activeTab == 'Productos'
                              ? 'productos'
                              : _activeTab == 'Usuarios'
                                  ? 'usuarios'
                                  : 'compras'
                        ).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: primaryPurple));
                          }

                          List<Map<String, dynamic>> items = [];

                          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                            for (var doc in snapshot.data!.docs) {
                              final data = doc.data() as Map<String, dynamic>;
                              data['id'] = doc.id;
                              items.add(data);
                            }
                          } else {
                            // Fallback to beautiful mock data matching the image if collection is empty
                            items = _activeTab == 'Productos'
                                ? _mockProducts
                                : _activeTab == 'Usuarios'
                                    ? _mockUsers
                                    : _mockPurchases;
                          }

                          return _buildDataTable(items);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper to build a tab button
  Widget _buildTabButton(String tabTitle) {
    const primaryPurple = Color(0xFFB000FF);
    final bool isActive = _activeTab == tabTitle;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _activeTab = tabTitle;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: isActive ? primaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isActive ? primaryPurple : Colors.purple.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              tabTitle,
              style: TextStyle(
                color: isActive ? Colors.white : primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Builds the scrollable Datatable inside the card
  Widget _buildDataTable(List<Map<String, dynamic>> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.purple.withValues(alpha: 0.05),
          ),
          child: DataTable(
            columnSpacing: 24.0,
            headingRowColor: WidgetStateProperty.all(Colors.purple.withValues(alpha: 0.02)),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2C59),
              fontSize: 14,
            ),
            dataTextStyle: const TextStyle(
              color: Color(0xFF0F2C59),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            columns: _getColumns(),
            rows: List<DataRow>.generate(
              items.length,
              (index) {
                final item = items[index];
                final String docId = item['id'].toString();
                final String displayName = _activeTab == 'Productos'
                    ? (item['title'] ?? item['nombre'] ?? '')
                    : _activeTab == 'Usuarios'
                        ? (item['nombre'] ?? '')
                        : (item['usuario'] ?? '');

                return DataRow(
                  color: WidgetStateProperty.all(
                    index % 2 == 0 ? Colors.white : const Color(0xFFF9F0FF),
                  ),
                  cells: _getCells(item, index, docId, displayName),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Defines dynamic column names based on the active tab
  List<DataColumn> _getColumns() {
    if (_activeTab == 'Productos') {
      return const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Acc')),
      ];
    } else if (_activeTab == 'Usuarios') {
      return const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Rol')),
        DataColumn(label: Text('Acc')),
      ];
    } else {
      return const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Usuario')),
        DataColumn(label: Text('Total')),
        DataColumn(label: Text('Fecha')),
        DataColumn(label: Text('Acc')),
      ];
    }
  }

  // Generates cells based on data structure
  List<DataCell> _getCells(Map<String, dynamic> item, int index, String docId, String displayName) {
    const primaryPurple = Color(0xFFB000FF);

    List<DataCell> cells = [
      DataCell(Text(
        _formatId(docId),
        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple),
      )),
    ];

    if (_activeTab == 'Productos') {
      double price = (item['price'] ?? item['precio'] ?? 0.0).toDouble();
      int stock = item['stock'] ?? 100;
      cells.addAll([
        DataCell(Text(displayName, style: const TextStyle(color: primaryPurple))),
        DataCell(Text('\$${price.toStringAsFixed(0)}', style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold))),
        DataCell(Text('$stock', style: const TextStyle(color: primaryPurple))),
      ]);
    } else if (_activeTab == 'Usuarios') {
      String email = item['email'] ?? '';
      String rol = item['rol'] ?? 'cliente';
      cells.addAll([
        DataCell(Text(displayName, style: const TextStyle(color: primaryPurple))),
        DataCell(Text(email)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rol == 'administrador' ? const Color(0xFFF5E6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rol,
            style: TextStyle(
              color: rol == 'administrador' ? primaryPurple : const Color(0xFF0F2C59),
              fontWeight: rol == 'administrador' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        )),
      ]);
    } else if (_activeTab == 'Pedidos') {
      double total = (item['total'] ?? 0.0).toDouble();
      String fecha = item['fecha'] ?? '';
      cells.addAll([
        DataCell(Text(displayName, style: const TextStyle(color: primaryPurple))),
        DataCell(Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold))),
        DataCell(Text(fecha)),
      ]);
    }

    // Dynamic actions column cells
    cells.add(
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 20),
            onPressed: () => _showEditDialog(docId, item),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _showDeleteConfirm(docId, displayName),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      )),
    );

    return cells;
  }
}
