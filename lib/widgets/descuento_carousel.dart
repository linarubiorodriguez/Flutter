import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constans.dart';

class DescuentoCarousel extends StatefulWidget {
  const DescuentoCarousel({super.key});

  @override
  State<DescuentoCarousel> createState() => _DescuentoCarouselState();
}

class _DescuentoCarouselState extends State<DescuentoCarousel> {
  final ScrollController _scrollController = ScrollController();
  final double itemWidth = 160;
  List<dynamic> descuentos = [];

  @override
  void initState() {
    super.initState();
    fetchDescuentos();
  }

  Future<void> fetchDescuentos() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/descuentosProd'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          descuentos = data['descuentos'];
        });
      } else {
        print('Error al obtener descuentos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con la API: $e');
    }
  }

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - itemWidth * 2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + itemWidth * 2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              itemCount: descuentos.length,
              itemBuilder: (context, index) {
                final descuento = descuentos[index];
                final producto = descuento['producto'];
                if (producto == null) return const SizedBox();
                final precioOriginal = producto['precio'];
                final porcentaje = descuento['porcentaje_descuento'];
                final precioDescuento = precioOriginal - (precioOriginal * porcentaje / 100);

                return Container(
                  width: itemWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      producto['imagen'] != null
                          ? Image.network(producto['imagen'], width: 80, height: 80, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 60, color: Constants.naranjaClaro),
                      const SizedBox(height: 5),
                      Text(producto['nombre'], style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\$${precioDescuento.toStringAsFixed(1)}',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          Text('\$${precioOriginal.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Icon(Icons.add_shopping_cart, color: Constants.naranjaOscuro),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 80,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
              onPressed: scrollLeft,
            ),
          ),
          Positioned(
            right: 0,
            top: 80,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onPressed: scrollRight,
            ),
          ),
        ],
      ),
    );
  }
}
