import 'cart_item.dart';

class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get productCount => items.length;

  int get totalQuantity =>
      items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount =>
      items.fold(0, (total, item) => total + item.subtotal);

  bool contains(int productId) =>
      items.any((item) => item.productId == productId);
}
