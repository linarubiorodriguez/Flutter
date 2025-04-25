class Product {
  final String id;
  final String name;
  final String brand;
  final String brandId;
  final String category;
  final String categoryId;
  final String animal;
  final String animalId;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.brandId,
    required this.category,
    required this.categoryId,
    required this.animal,
    required this.animalId,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['nombre'],
      brand: json['marca'],
      brandId: json['marca_id'].toString(),
      category: json['categoria'],
      categoryId: json['categoria_id'].toString(),
      animal: json['animal'],
      animalId: json['animal_id'].toString(),
      price: double.parse(json['precio'].toString()),
    );
  }
}
