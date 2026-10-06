import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cart_storage.dart';
import '../domain/entities/cart_item.dart';

const _storageKey = 'cart_items';

class SharedPreferencesCartStorage implements CartStorage {
  const SharedPreferencesCartStorage(this._preferences);

  final SharedPreferences _preferences;

  @override
  List<CartItem> read() {
    final stored = _preferences.getString(_storageKey);
    if (stored == null) {
      return const [];
    }

    try {
      return (jsonDecode(stored) as List<dynamic>)
          .map((item) => _toCartItem(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> save(List<CartItem> items) {
    return _preferences.setString(
      _storageKey,
      jsonEncode(items.map(_toJson).toList()),
    );
  }

  Map<String, dynamic> _toJson(CartItem item) {
    return {
      'productId': item.productId,
      'title': item.title,
      'price': item.price,
      'thumbnail': item.thumbnail,
      'quantity': item.quantity,
    };
  }

  CartItem _toCartItem(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
