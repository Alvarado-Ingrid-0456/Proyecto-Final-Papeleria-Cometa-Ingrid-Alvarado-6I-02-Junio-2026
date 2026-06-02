import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.usuarioDatos?.isAdmin == true;

    // Get the current active route name to dynamically highlight the active menu item
    final currentRoute = ModalRoute.of(context)?.settings.name;

    const primaryPurple = Color(0xFFB000FF);
    const textDarkBlue = Color(0xFF0F2C59);
    const highlightBg = Color(0xFFF5E6FF);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header matching the mockup
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50.0, left: 20.0, bottom: 20.0, right: 20.0),
            decoration: const BoxDecoration(
              color: primaryPurple,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 48,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Papelería Cometa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tu papelería favorita',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              children: [
                _buildDrawerItem(
                  context,
                  title: 'Inicio',
                  icon: Icons.home_outlined,
                  routeName: '/home',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Impresiones',
                  icon: Icons.print_outlined,
                  routeName: '/impresiones',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Útiles',
                  icon: Icons.edit_outlined,
                  routeName: '/utiles',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Libretas',
                  icon: Icons.menu_book_outlined,
                  routeName: '/libretas',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Arte',
                  icon: Icons.palette_outlined,
                  routeName: '/arte',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Manualidades',
                  icon: Icons.content_cut_outlined,
                  routeName: '/manualidades',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Regalos',
                  icon: Icons.card_giftcard_outlined,
                  routeName: '/regalos',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Carrito',
                  icon: Icons.shopping_cart_outlined,
                  routeName: '/cart',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Mis Pedidos',
                  icon: Icons.receipt_long_outlined,
                  routeName: '/mis-pedidos',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Colors.black12, height: 1),
                ),
                _buildDrawerItem(
                  context,
                  title: 'Cuenta',
                  icon: Icons.person_outline,
                  routeName: '/account',
                  currentRoute: currentRoute,
                  activeColor: primaryPurple,
                  inactiveColor: textDarkBlue,
                  activeBgColor: highlightBg,
                ),

                // Special Admin Panel option, visible to administrators only
                if (isAdmin)
                  _buildDrawerItem(
                    context,
                    title: 'Panel Admin',
                    icon: Icons.admin_panel_settings_outlined,
                    routeName: '/admin_dashboard',
                    currentRoute: currentRoute,
                    activeColor: primaryPurple,
                    inactiveColor: Colors.amber[800]!,
                    activeBgColor: highlightBg,
                  ),

                _buildDrawerItem(
                  context,
                  title: 'Cerrar sesión',
                  icon: Icons.logout_outlined,
                  routeName: 'logout',
                  currentRoute: currentRoute,
                  activeColor: Colors.red,
                  inactiveColor: Colors.red,
                  activeBgColor: highlightBg,
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
    required String? currentRoute,
    required Color activeColor,
    required Color inactiveColor,
    required Color activeBgColor,
    VoidCallback? onTap,
  }) {
    final bool isActive = currentRoute == routeName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 24,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onTap: onTap ??
              () {
                // If it's already on the active route, just close the drawer
                if (isActive) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(routeName);
                }
              },
        ),
      ),
    );
  }
}
