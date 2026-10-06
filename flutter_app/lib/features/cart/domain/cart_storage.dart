import 'entities/cart_item.dart';

abstract class CartStorage {
  List<CartItem> read();

  Future<void> save(List<CartItem> items);
}
