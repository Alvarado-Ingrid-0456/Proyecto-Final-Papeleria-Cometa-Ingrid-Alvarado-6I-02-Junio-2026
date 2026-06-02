import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock carousel data to enable interactive chevron clicks/swipes if desired
  int _currentCarouselIndex = 0;
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Jueves de Libretas',
      'description': '¡Escribe 100 hojas cuadrícula al 2x1!!!',
    },
    {
      'icon': Icons.local_offer_rounded,
      'title': 'Descuento Escolar',
      'description': '15% de descuento en todos los útiles escolares.',
    },
    {
      'icon': Icons.palette_rounded,
      'title': 'Mes del Arte',
      'description': 'Compra 2 acuarelas y llévate un pincel gratis.',
    },
  ];

  void _nextCarousel() {
    setState(() {
      _currentCarouselIndex = (_currentCarouselIndex + 1) % _carouselItems.length;
    });
  }

  void _prevCarousel() {
    setState(() {
      _currentCarouselIndex =
          (_currentCarouselIndex - 1 + _carouselItems.length) % _carouselItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFB000FF);
    const backgroundColor = Color(0xFFF5E6FF);

    final carouselItem = _carouselItems[_currentCarouselIndex];

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
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Carousel Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 16.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Chevron Button
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: primaryPurple, size: 36),
                      onPressed: _prevCarousel,
                    ),
                    // Banner Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            carouselItem['icon'] as IconData,
                            size: 64,
                            color: primaryPurple,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            carouselItem['title'] as String,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryPurple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            carouselItem['description'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              color: primaryPurple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Dot Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _carouselItems.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentCarouselIndex == index
                                      ? primaryPurple
                                      : primaryPurple.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right Chevron Button
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: primaryPurple, size: 36),
                      onPressed: _nextCarousel,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Grid of Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Impresiones',
                    icon: Icons.print_rounded,
                    iconBgColor: const Color(0xFF00A2FF),
                    routeName: '/impresiones',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Útiles',
                    icon: Icons.edit_rounded,
                    iconBgColor: const Color(0xFFB080FF),
                    routeName: '/utiles',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Libretas',
                    icon: Icons.menu_book_rounded,
                    iconBgColor: const Color(0xFFFF529D),
                    routeName: '/libretas',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Arte',
                    icon: Icons.palette_rounded,
                    iconBgColor: const Color(0xFFFF8800),
                    routeName: '/arte',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Manualidades',
                    icon: Icons.content_cut_rounded,
                    iconBgColor: const Color(0xFFFFC000),
                    routeName: '/manualidades',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Regalos',
                    icon: Icons.card_giftcard_rounded,
                    iconBgColor: const Color(0xFF00E1FF),
                    routeName: '/regalos',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            // Bottom Sparkle Decoration
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Icon(Icons.star, color: Colors.pinkAccent, size: 28),
                SizedBox(width: 12),
                Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(routeName);
      },
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Colored Icon Box
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            // Category Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB000FF), // Matching deep purple text
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
