import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MarcasCarousel extends StatefulWidget {
  const MarcasCarousel({super.key});

  @override
  _MarcasCarouselState createState() => _MarcasCarouselState();
}

class _MarcasCarouselState extends State<MarcasCarousel> {
  final ScrollController _scrollController = ScrollController();
  final double itemWidth = 120;
  List<dynamic> marcas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMarcas();
  }

  Future<void> fetchMarcas() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/PrivMarcas'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          marcas = data['marcas'];
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar marcas');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - itemWidth * 2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + itemWidth * 2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              itemCount: marcas.length,
              itemBuilder: (context, index) {
                final marca = marcas[index];
                final imageUrl = marca['imagen'];

                return Container(
                  width: itemWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Center(child: Icon(Icons.image, size: 50, color: Colors.orange)),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
              onPressed: scrollLeft,
            ),
          ),
          Positioned(
            right: 0,
            top: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
              onPressed: scrollRight,
            ),
          ),
        ],
      ),
    );
  }
}
