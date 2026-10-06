import 'product.dart';

class ProductsPage {
  const ProductsPage({
    required this.items,
    required this.total,
    required this.requested,
  });

  final List<Product> items;
  final int total;
  final int requested;
}
