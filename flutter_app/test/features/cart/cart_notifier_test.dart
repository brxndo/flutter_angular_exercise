import 'package:flutter_app/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeCartStorage storage;
  late ProviderContainer container;

  setUp(() {
    storage = FakeCartStorage();
    container = ProviderContainer.test(
      overrides: [cartStorageProvider.overrideWithValue(storage)],
    );
  });

  CartNotifier notifier() => container.read(cartProvider.notifier);

  test('arranca vacío y suma el primer producto', () {
    expect(container.read(cartProvider).isEmpty, isTrue);

    notifier().add(buildProduct(id: 1, price: 20));

    final cart = container.read(cartProvider);
    expect(cart.items, hasLength(1));
    expect(cart.items.first.quantity, 1);
    expect(cart.totalAmount, 20);
  });

  test('agregar dos veces el mismo producto incrementa la cantidad', () {
    final product = buildProduct(id: 1, price: 15);

    notifier()
      ..add(product)
      ..add(product);

    final cart = container.read(cartProvider);
    expect(cart.items, hasLength(1));
    expect(cart.items.first.quantity, 2);
    expect(cart.totalQuantity, 2);
    expect(cart.totalAmount, 30);
  });

  test('cambiar la cantidad a cero elimina el producto', () {
    notifier()
      ..add(buildProduct(id: 1))
      ..add(buildProduct(id: 2))
      ..updateQuantity(1, 0);

    final cart = container.read(cartProvider);
    expect(cart.items.map((item) => item.productId), [2]);
  });

  test('el total considera el precio con descuento de cada producto', () {
    notifier()
      ..add(buildProduct(id: 1, price: 100, discountPercentage: 10))
      ..updateQuantity(1, 3)
      ..add(buildProduct(id: 2, price: 50));

    expect(container.read(cartProvider).totalAmount, 320);
  });

  test('cada operación crea una lista nueva sin mutar la anterior', () {
    notifier().add(buildProduct(id: 1));
    final before = container.read(cartProvider).items;

    notifier().add(buildProduct(id: 2));
    final after = container.read(cartProvider).items;

    expect(before, hasLength(1));
    expect(after, hasLength(2));
    expect(identical(before, after), isFalse);
  });

  test('persiste el carrito y lo recupera al reconstruir el estado', () {
    notifier().add(buildProduct(id: 9, price: 5));
    expect(storage.saved, hasLength(1));

    final restored = ProviderContainer.test(
      overrides: [
        cartStorageProvider.overrideWithValue(FakeCartStorage(storage.saved)),
      ],
    );

    expect(restored.read(cartProvider).items.single.productId, 9);
  });

  test('vaciar el carrito deja el estado y el almacenamiento sin productos', () {
    notifier()
      ..add(buildProduct(id: 1))
      ..clear();

    expect(container.read(cartProvider).isEmpty, isTrue);
    expect(storage.saved, isEmpty);
  });

  test('copyWith del item solo cambia la cantidad', () {
    const item = CartItem(
      productId: 1,
      title: 'Producto',
      price: 10,
      thumbnail: 'url',
      quantity: 1,
    );

    final updated = item.copyWith(quantity: 4);

    expect(updated.productId, item.productId);
    expect(updated.quantity, 4);
    expect(updated.subtotal, 40);
    expect(item.quantity, 1);
  });
}
