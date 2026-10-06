import 'cart_item.dart';

class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity =>
      items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount =>
      items.fold(0, (total, item) => total + item.subtotal);
}
