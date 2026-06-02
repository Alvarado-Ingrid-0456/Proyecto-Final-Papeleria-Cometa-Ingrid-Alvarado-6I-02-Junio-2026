import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class CuentaScreen extends StatelessWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final profile = authProvider.usuarioDatos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
        centerTitle: true,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).pushNamed('/edit-account'),
              tooltip: 'Editar Perfil',
            ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (user != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                        backgroundImage: (profile?.imagenUrl != null && profile!.imagenUrl.isNotEmpty)
                            ? NetworkImage(profile.imagenUrl)
                            : (user.photoURL != null ? NetworkImage(user.photoURL!) : null),
                        child: (profile?.imagenUrl == null || profile!.imagenUrl.isEmpty) && user.photoURL == null
                            ? Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              profile?.nombre ?? user.displayName ?? 'Usuario',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              user.email ?? 'No email',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            if (profile != null && profile.rol == 'administrador') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'Administrador',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Detalles del Perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Teléfono'),
                        subtitle: Text(
                          profile?.telefono != null && profile!.telefono.isNotEmpty
                              ? profile.telefono
                              : 'No especificado',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text('Dirección de Envío'),
                        subtitle: Text(
                          profile?.direccion != null && profile!.direccion.isNotEmpty
                              ? profile.direccion
                              : 'No especificada',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              const Center(child: Text('No has iniciado sesión.')),
            const SizedBox(height: 24),
            if (profile?.isAdmin == true) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.amber),
                title: const Text('Panel de Administración', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
                onTap: () => Navigator.of(context).pushNamed('/admin_dashboard'),
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Mis Pedidos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).pushNamed('/mis-pedidos');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar Perfil'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).pushNamed('/edit-account'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
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
    );
  }
}
