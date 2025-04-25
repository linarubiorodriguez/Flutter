import 'package:flutter/material.dart';
import '../constans.dart';
import '../widgets/marcas_carousel.dart';
import '../widgets/descuento_carousel.dart';
import './perfil_page.dart';
import './carrito_page.dart';
import './search_results_page.dart'; // Asegúrate de tener esta página

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const CarritoPage(),
    PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Constants.naranjaClaro,
        selectedItemColor: Constants.naranjamasOscuro,
        unselectedItemColor: Constants.naranjaOscuro,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchTextController = TextEditingController();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Image.asset('../../assets/imagen/logo.png', width: 80, height: 80),
                const SizedBox(width: 8),
                const Text(
                  'El Escondite Animal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Constants.naranjaOscuro,
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: TextField(
              controller: _searchTextController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsPage(searchQuery: value.trim()),
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos',
                prefixIcon: Icon(Icons.search, color: Constants.naranjaClaro),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              '../../assets/imagen/principal.png',
              width: 400,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Categorías',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Constants.naranjaOscuro,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildCategory('Juguetes', '../../assets/imagen/juguetes.png'),
                _buildCategory('Comidas', '../../assets/imagen/comidas.png'),
                _buildCategory('Accesorios', '../../assets/imagen/accesorios.png'),
                _buildCategory('Camas', '../../assets/imagen/camas.png'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Productos en descuento',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constants.naranjaOscuro,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const DescuentoCarousel(),

          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Marcas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constants.naranjaOscuro,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const MarcasCarousel(),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(16),
            color: Constants.naranjaClaro.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Visítanos en nuestras redes sociales:',
                  style: TextStyle(
                    color: Constants.naranjaOscuro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.tiktok, color: Constants.naranjaOscuro),
                    SizedBox(width: 16),
                    Icon(Icons.facebook, color: Constants.naranjaOscuro),
                    SizedBox(width: 16),
                    Icon(Icons.camera_alt, color: Constants.naranjaOscuro),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contacto:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Constants.naranjaOscuro,
                  ),
                ),
                const Text(
                  'Elesconditeanimal@gmail.com',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCategory(String title, String imagePath) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              width: 150,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Constants.naranjaOscuro,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          )
        ],
      ),
    );
  }
}
