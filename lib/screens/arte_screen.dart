import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/widgets/navigation_drawer.dart';
import 'package:myapp/screens/product_detail_screen.dart';

// Dummy fallback data for art items
final List<Map<String, dynamic>> _artItemsFallback = [
  {
    'id': 'a1',
    'name': 'Set de Acuarelas Viajero',
    'description': 'Compacto y completo para pintar en cualquier lugar.',
    'price': 28.00,
    'imageUrl': 'https://picsum.photos/seed/art1/200/300',
  },
  {
    'id': 'a2',
    'name': 'Lienzo Profesional (Pack de 3)',
    'description': 'Lienzos de algodón imprimados, listos para usar.',
    'price': 40.00,
    'imageUrl': 'https://picsum.photos/seed/art2/200/300',
  },
  {
    'id': 'a3',
    'name': 'Curso de Dibujo a Lápiz',
    'description': 'Aprende desde los fundamentos hasta técnicas avanzadas.',
    'price': 60.00,
    'imageUrl': 'https://picsum.photos/seed/art3/200/300',
  },
];

class ArteScreen extends StatelessWidget {
  const ArteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arte y Materiales'),
        centerTitle: true,
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          List<Map<String, dynamic>> items = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final docs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final cat = data['category'] ?? data['categoria'] ?? '';
              return cat.toString().toLowerCase() == 'arte';
            }).toList();

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              items.add(data);
            }
          }

          // Fallback if Firestore has no art items
          if (items.isEmpty) {
            items = _artItemsFallback;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final art = items[i];
              final String docId = art['id'].toString();
              final String name = art['title'] ?? art['name'] ?? '';
              final String desc = art['description'] ?? '';
              final double price = (art['price'] ?? art['precio'] ?? 0.0).toDouble();
              final String imgUrl = art['imageUrl'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (docId.startsWith('a1') || docId.startsWith('a2') || docId.startsWith('a3')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viendo detalles de prueba para: $name')),
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: docId,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Art Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: imgUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(imgUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imgUrl.isEmpty
                              ? Icon(Icons.image_not_supported, color: Colors.grey[400])
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                desc,
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
