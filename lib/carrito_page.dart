import 'package:flutter/material.dart';
import 'carrito_model.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  Map<int, int> cantidades = {}; // productoIndex : cantidad

  @override
  Widget build(BuildContext context) {
    final productos = Carrito.obtenerProductos();

    // Asegura que cada producto tenga cantidad inicial 1
    for (int i = 0; i < productos.length; i++) {
      cantidades[i] = cantidades[i] ?? 1;
    }

    // Calcular totales
    double subtotal = 0.0;
    for (int i = 0; i < productos.length; i++) {
      final precio = double.tryParse(productos[i]['precio'].toString()) ?? 0.0;
      final cantidad = cantidades[i] ?? 1;
      subtotal += precio * cantidad;
    }
    final iva = subtotal * 0.16;
    final total = subtotal + iva;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.shopping_cart, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Carrito',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de productos
            Expanded(
              child: productos.isEmpty
                  ? const Center(child: Text('No hay productos en el carrito'))
                  : ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        final imagePath = producto['imagen']?.toString() ?? '';
                        final imageUrl = imagePath.startsWith('http')
                            ? imagePath
                            : 'http://127.0.0.1:5000/${imagePath.replaceFirst(RegExp(r"^/"), "")}';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto['nombre'] ?? 'Título',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text("Categoría", style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                // Precio y controles
                                Column(
                                  children: [
                                    Text(
                                      '\$${double.tryParse(producto['precio'].toString())?.toStringAsFixed(1) ?? '0.0'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.orange),
                                          onPressed: () {
                                            setState(() {
                                              if ((cantidades[index] ?? 1) > 1) {
                                                cantidades[index] = (cantidades[index] ?? 1) - 1;
                                              }
                                            });
                                          },
                                        ),
                                        Text(
                                          '${cantidades[index] ?? 1}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle, color: Colors.orange),
                                          onPressed: () {
                                            setState(() {
                                              cantidades[index] = (cantidades[index] ?? 1) + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          productos.removeAt(index);
                                          cantidades.remove(index);
                                          // Reindexar para evitar errores en el map
                                          cantidades = {
                                            for (int i = 0; i < productos.length; i++) i: cantidades[i] ?? 1
                                          };
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Total y botón
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal:"),
                      Text("\$${subtotal.toStringAsFixed(1)}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("IVA (16%):"),
                      Text("\$${iva.toStringAsFixed(1)}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "\$${total.toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // lógica de pago
                    },
                    child: const Text(
                      'Proceder',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
