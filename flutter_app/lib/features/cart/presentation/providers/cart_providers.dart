import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/preferences_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../data/shared_preferences_cart_storage.dart';
import '../../domain/cart_storage.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_state.dart';

final cartStorageProvider = Provider<CartStorage>((ref) {
  return SharedPreferencesCartStorage(ref.watch(sharedPreferencesProvider));
});

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState(items: ref.watch(cartStorageProvider).read());

  void add(Product product) {
    final alreadyInCart = state.items.any((item) => item.productId == product.id);

    if (!alreadyInCart) {
      _emit([...state.items, _itemFrom(product)]);
      return;
    }

    _emit([
      for (final item in state.items)
        if (item.productId == product.id)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ]);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }

    _emit([
      for (final item in state.items)
        if (item.productId == productId) item.copyWith(quantity: quantity) else item,
    ]);
  }

  void remove(int productId) {
    _emit(state.items.where((item) => item.productId != productId).toList());
  }

  void clear() => _emit(const []);

  void _emit(List<CartItem> items) {
    state = CartState(items: items);
    ref.read(cartStorageProvider).save(items);
  }

  CartItem _itemFrom(Product product) {
    return CartItem(
      productId: product.id,
      title: product.title,
      price: product.finalPrice,
      thumbnail: product.thumbnail,
      quantity: 1,
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
