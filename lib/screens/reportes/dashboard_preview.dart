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
    'ventas': 0.0,  // Cambiado a double para manejar decimales
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
      if (!mounted) return;
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

      if (!mounted) return;
      
      final List<dynamic> ventasData = jsonDecode(ventasRes.body);
      final productosData = jsonDecode(productosRes.body);
      final usuariosData = jsonDecode(usuariosRes.body);

      // Calcular el total sumando todos los valores de venta
      double totalVentas = 0.0;
      for (var venta in ventasData) {
        totalVentas += _parseDouble(venta['total']);
      }

      setState(() {
        data = {
          'ventas': totalVentas,
          'productosTop': (productosData['top_productos'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          'usuarios': {
            'activos': _safeParseInt(usuariosData['usuarios_activos']),
            'nuevos': _safeParseInt(usuariosData['nuevos_clientes']),
          }
        };
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error completo: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }
  
  int _safeParseInt(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        // Intenta parsear directamente
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        
        // Si falla, intenta eliminar caracteres no numéricos
        final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(numericString) ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error parsing int from $value: $e');
      return 0;
    }
  }

  double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Intenta parsear directamente
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
        
        // Si falla, intenta eliminar caracteres no numéricos (excepto punto)
        final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(numericString) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error parsing double from $value: $e');
      return 0.0;
    }
  }
  // Método auxiliar para parsear ints
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
    // Asegúrate de que siempre sea double
    final sales = (data['ventas'] is int) 
        ? (data['ventas'] as int).toDouble()
        : (data['ventas'] as double? ?? 0.0);

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
              '\$${sales.toStringAsFixed(2)}',
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
    final usuarios = data['usuarios'] as Map<String, dynamic>;
    final usuariosActivos = _safeParseInt(usuarios['activos']);
    final nuevosClientes = _safeParseInt(usuarios['nuevos']);
    
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
              usuariosActivos.toString(),
              style: const TextStyle(fontSize: 32, color: Colors.green),
            ),
            Text(
              'Nuevos: $nuevosClientes (30 días)',
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
    // Convertir la lista dinámica a una lista tipada
    final List<Map<String, dynamic>> productos = 
        List<Map<String, dynamic>>.from(data['productosTop']);

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
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final product = productos[index];
                  final ingresos = _parseDouble(product['ingresos']);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product['nombre']?.toString() ?? ''),
                        Text(
                          '\$${ingresos.toStringAsFixed(2)}',
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