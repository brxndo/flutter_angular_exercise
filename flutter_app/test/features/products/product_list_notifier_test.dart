import 'package:flutter_app/core/errors/failure.dart';
import 'package:flutter_app/features/products/presentation/providers/product_list_notifier.dart';
import 'package:flutter_app/features/products/presentation/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  ProviderContainer containerWith(FakeProductRepository repository) {
    return ProviderContainer.test(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('carga la primera página y sabe que quedan más productos', () async {
    final repository = FakeProductRepository(
      total: 4,
      pages: {0: [buildProduct(id: 1), buildProduct(id: 2)]},
    );
    final container = containerWith(repository);

    final state = await container.read(productListProvider.future);

    expect(state.items, hasLength(2));
    expect(state.loadedCount, 2);
    expect(state.hasMore, isTrue);
    expect(repository.requestedSkips, [0]);
  });

  test('loadMore concatena la siguiente página sin duplicar', () async {
    final repository = FakeProductRepository(
      total: 4,
      pages: {
        0: [buildProduct(id: 1), buildProduct(id: 2)],
        2: [buildProduct(id: 3), buildProduct(id: 4)],
      },
    );
    final container = containerWith(repository);
    await container.read(productListProvider.future);

    await container.read(productListProvider.notifier).loadMore();

    final state = container.read(productListProvider).value;
    expect(state?.items.map((product) => product.id), [1, 2, 3, 4]);
    expect(state?.hasMore, isFalse);
    expect(repository.requestedSkips, [0, 2]);
  });

  test('no vuelve a pedir cuando ya cargó todo', () async {
    final repository = FakeProductRepository(
      total: 1,
      pages: {0: [buildProduct(id: 1)]},
    );
    final container = containerWith(repository);
    await container.read(productListProvider.future);

    await container.read(productListProvider.notifier).loadMore();

    expect(repository.requestedSkips, [0]);
  });

  test('un Left deja el estado en error con el Failure tipado', () async {
    final container = containerWith(
      FakeProductRepository(failure: const NetworkFailure('Sin conexión')),
    );

    await expectLater(
      container.read(productListProvider.future),
      throwsA(anything),
    );

    final state = container.read(productListProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<NetworkFailure>());
  });

  test('si falla el loadMore conserva lo cargado y expone el error del footer', () async {
    final repository = FakeProductRepository(
      total: 4,
      pages: {0: [buildProduct(id: 1), buildProduct(id: 2)]},
    );
    final container = containerWith(repository);
    await container.read(productListProvider.future);

    repository.failure = const ServerFailure('El servidor respondió 500');
    await container.read(productListProvider.notifier).loadMore();

    final state = container.read(productListProvider).value;
    expect(state?.items, hasLength(2));
    expect(state?.isLoadingMore, isFalse);
    expect(state?.loadMoreFailure, isA<ServerFailure>());
  });

  test('cambiar la búsqueda reinicia la paginación desde cero', () async {
    final repository = FakeProductRepository(
      total: 4,
      pages: {
        0: [buildProduct(id: 1), buildProduct(id: 2)],
        2: [buildProduct(id: 3), buildProduct(id: 4)],
      },
    );
    final container = containerWith(repository);
    await container.read(productListProvider.future);
    await container.read(productListProvider.notifier).loadMore();

    container.read(searchQueryProvider.notifier).clear();
    container.read(selectedCategoryProvider.notifier).toggle('beauty');
    final state = await container.read(productListProvider.future);

    expect(state.items, hasLength(2));
    expect(state.loadedCount, 2);
    expect(repository.requestedSkips, [0, 2, 0]);
  });
}
