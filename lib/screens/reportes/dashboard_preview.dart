import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPreview extends StatefulWidget {
  final String token;
  final Function(int) onViewDetails;

  const DashboardPreview({
    super.key,
    required this.token,
    required this.onViewDetails,
  });

  @override
  _DashboardPreviewState createState() => _DashboardPreviewState();
}

class _DashboardPreviewState extends State<DashboardPreview> {
  Map<String, dynamic> data = {
    'ventas': 0,
    'productosTop': [],
    'usuarios': {'activos': 0, 'nuevos': 0}
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => isLoading = true);
      
      final ventasRes = await http.get(
        Uri.parse('http://localhost:5000/api/reportes/ventas?limit=7'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      
      final productosRes = await http.get(
        Uri.parse('http://localhost:5000/api/reportes/productos?limit=3'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      
      final usuariosRes = await http.get(
        Uri.parse('http://localhost:5000/api/reportes/usuarios'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      setState(() {
        data = {
          'ventas': jsonDecode(ventasRes.body)['total'] ?? 0,
          'productosTop': jsonDecode(productosRes.body)['top_productos'] ?? [],
          'usuarios': {
            'activos': jsonDecode(usuariosRes.body)['usuarios_activos'] ?? 0,
            'nuevos': jsonDecode(usuariosRes.body)['nuevos_clientes'] ?? 0,
          }
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildSalesCard(),
              _buildUsersCard(),
              _buildProductsCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ventas (7 días)', style: TextStyle(fontSize: 18)),
            const Spacer(),
            Text(
              '\$${data['ventas'].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, color: Colors.blue),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onViewDetails(0),
                child: const Text('Ver Detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Usuarios Activos', style: TextStyle(fontSize: 18)),
            const Spacer(),
            Text(
              data['usuarios']['activos'].toString(),
              style: const TextStyle(fontSize: 32, color: Colors.green),
            ),
            Text(
              'Nuevos: ${data['usuarios']['nuevos']} (30 días)',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onViewDetails(2),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Ver Detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productos Destacados', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: data['productosTop'].length,
                itemBuilder: (context, index) {
                  final product = data['productosTop'][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product['nombre'] ?? ''),
                        Text(
                          '\$${product['ingresos'].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onViewDetails(1),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Ver Stock Completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}