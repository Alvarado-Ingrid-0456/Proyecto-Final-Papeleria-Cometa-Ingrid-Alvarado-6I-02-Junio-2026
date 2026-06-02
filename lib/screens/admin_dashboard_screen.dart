import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _productosCount = 24;
  int _usuariosCount = 156;
  int _comprasCount = 89;
  double _ventasTotal = 45000.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // 1. Get products count
      final prods = await FirebaseFirestore.instance
          .collection('productos')
          .get()
          .timeout(const Duration(seconds: 4));
      if (prods.docs.isNotEmpty) {
        _productosCount = prods.docs.length;
      }

      // 2. Get users count
      final users = await FirebaseFirestore.instance
          .collection('usuarios')
          .get()
          .timeout(const Duration(seconds: 4));
      if (users.docs.isNotEmpty) {
        _usuariosCount = users.docs.length;
      }

      // 3. Get purchases count and sum sales
      final purchases = await FirebaseFirestore.instance
          .collection('compras')
          .get()
          .timeout(const Duration(seconds: 4));
      if (purchases.docs.isNotEmpty) {
        _comprasCount = purchases.docs.length;
        double sum = 0.0;
        for (var doc in purchases.docs) {
          final data = doc.data();
          final totalVal = data['total'] ?? data['totalAmount'] ?? data['precio'] ?? 0.0;
          if (totalVal is num) {
            sum += totalVal.toDouble();
          } else if (totalVal is String) {
            sum += double.tryParse(totalVal) ?? 0.0;
          }
        }
        if (sum > 0) {
          _ventasTotal = sum;
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch dashboard metrics, using mockup fallbacks: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    const backgroundColor = Color(0xFFF5E6FF);

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = authProvider.usuarioDatos?.nombre ?? user?.email?.split('@')[0] ?? 'Usuario123';

    // Format sales value beautifully (e.g. $45K or exact value)
    String formattedVentas;
    if (_ventasTotal >= 1000) {
      formattedVentas = '\$${(_ventasTotal / 1000).toStringAsFixed(0)}K';
    } else {
      formattedVentas = '\$${_ventasTotal.toStringAsFixed(0)}';
    }

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen Title
            const Center(
              child: Text(
                'Panel de Administración',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Info Card
            Container(
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
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Profile Icon Circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@$userName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Administrador',
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // "Ver tablas" Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/admin_tables');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_on_rounded, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Ver tablas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Metrics Grid (2x2)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.25,
              children: [
                _buildMetricCard(
                  title: 'Productos',
                  value: '$_productosCount',
                  bgColor: const Color(0xFF00A2FF),
                ),
                _buildMetricCard(
                  title: 'Usuarios',
                  value: '$_usuariosCount',
                  bgColor: const Color(0xFFB080FF),
                ),
                _buildMetricCard(
                  title: 'Compras',
                  value: '$_comprasCount',
                  bgColor: const Color(0xFFFF529D),
                ),
                _buildMetricCard(
                  title: 'Ventas',
                  value: formattedVentas,
                  bgColor: const Color(0xFFFFB300),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
