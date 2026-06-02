
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/providers/product_provider.dart';

import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/catalog_screen.dart';
import 'package:myapp/screens/product_detail_screen.dart';
import 'package:myapp/screens/cart_screen.dart';
import 'package:myapp/screens/cuenta_screen.dart';
import 'package:myapp/screens/pagar_compra_screen.dart';
import 'package:myapp/screens/order_success_screen.dart';
import 'package:myapp/screens/editar_cuenta_screen.dart';
import 'package:myapp/screens/admin_login_screen.dart';
import 'package:myapp/screens/admin_dashboard_screen.dart';
import 'package:myapp/screens/admin_tables_screen.dart';
import 'package:myapp/screens/mis_pedidos_screen.dart';

// Import category screens
import 'package:myapp/screens/impresiones_screen.dart';
import 'package:myapp/screens/utiles_screen.dart';
import 'package:myapp/screens/libretas_screen.dart';
import 'package:myapp/screens/arte_screen.dart';
import 'package:myapp/screens/manualidades_screen.dart';
import 'package:myapp/screens/regalos_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Papelería Cometa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFB000FF),
            primary: const Color(0xFFB000FF),
            secondary: Colors.pinkAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFB000FF),
            foregroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/catalog': (context) => const CatalogScreen(),
          ProductDetailScreen.routeName: (context) => const ProductDetailScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          '/account': (context) => const CuentaScreen(),
          '/edit-account': (context) => const EditarCuentaScreen(),
          '/payment': (context) => const PagarCompraScreen(),
          '/order-success':(context) => const OrderSuccessScreen(),
          '/mis-pedidos': (context) => const MisPedidosScreen(),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin_dashboard': (context) => const AdminDashboardScreen(),
          '/admin_tables': (context) => const AdminTablesScreen(),
          
          // Category routes
          '/impresiones': (context) => const ImpresionesScreen(),
          '/utiles': (context) => const UtilesScreen(),
          '/libretas': (context) => const LibretasScreen(),
          '/arte': (context) => const ArteScreen(),
          '/manualidades': (context) => const ManualidadesScreen(),
          '/regalos': (context) => const RegalosScreen(),
        },
      ),
    );
  }
}
