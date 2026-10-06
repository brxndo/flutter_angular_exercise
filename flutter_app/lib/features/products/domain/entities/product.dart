class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    this.brand,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final String? brand;

  bool get hasDiscount => discountPercentage > 0;

  bool get isAvailable => stock > 0;

  double get finalPrice => price - (price * discountPercentage / 100);
}
