class Carrito {
  static final List<Map<String, dynamic>> _productos = [];

  static void agregarProducto(Map<String, dynamic> producto) {
    _productos.add(producto); // Agrega sin reemplazar
  }

  static List<Map<String, dynamic>> obtenerProductos() {
    return _productos;
  }

  static double obtenerTotal() {
    return _productos.fold(0.0, (total, item) {
      final precio = double.tryParse(item['precio'].toString()) ?? 0.0;
      return total + precio;
    });
  }

  static void limpiarCarrito() {
    _productos.clear();
  }
}
