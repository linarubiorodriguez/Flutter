import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'carrito_model.dart';

class SearchResultsPage extends StatefulWidget {
  final String? searchQuery;

  const SearchResultsPage({super.key, this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final String apiUrl = "http://127.0.0.1:5000";

  List<dynamic> products = [];
  String? selectedAnimal;

  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.text = widget.searchQuery ?? '';
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      setState(() => isLoading = true);
      final res = await http.get(Uri.parse('$apiUrl/PrivProd'));
      final jsonData = json.decode(res.body);
      setState(() {
        products = jsonData['productos'];
      });
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get filteredProducts {
    final query = searchController.text.toLowerCase();
    return products.where((product) {
      final name = product['nombre']?.toString().toLowerCase() ?? '';
      final animalId = product['id_animal']?.toString();

      final matchesSearch = query.isEmpty || name.contains(query);
      final matchesAnimal = selectedAnimal == null || animalId == selectedAnimal;

      return matchesSearch && matchesAnimal;
    }).toList();
  }

  void onAnimalFilter(String? idAnimal) {
    setState(() => selectedAnimal = idAnimal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: const Color(0xFFFFF1EC),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.orange),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Resultados',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orangeAccent),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search, color: Colors.orange),
                              hintText: "Buscar productos",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Filtros",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildAnimalChip("Todo", null),
                            _buildAnimalChip("Perros", "2"),
                            _buildAnimalChip("Gatos", "1"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        itemCount: filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];

                          final imagePath = product['imagen']?.toString() ?? '';
                          final imageUrl = imagePath.startsWith('http')
                              ? imagePath
                              : '$apiUrl/${imagePath.replaceFirst(RegExp(r"^/"), "")}';

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 70, color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    product['nombre'] ?? 'Título',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '\$ ${double.tryParse(product['precio'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Carrito.agregarProducto(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Producto agregado al carrito'),
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.shopping_cart, color: Colors.orange),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAnimalChip(String label, String? idAnimal) {
    final isSelected = selectedAnimal == idAnimal;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onAnimalFilter(idAnimal),
        selectedColor: Colors.orange,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        shape: const StadiumBorder(side: BorderSide(color: Colors.orange)),
      ),
    );
  }
}
