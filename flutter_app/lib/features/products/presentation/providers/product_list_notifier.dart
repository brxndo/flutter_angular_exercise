import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/retry_policy.dart';
import '../../domain/entities/product.dart';
import 'product_providers.dart';

class ProductListState {
  const ProductListState({
    required this.items,
    required this.loadedCount,
    required this.total,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final List<Product> items;
  final int loadedCount;
  final int total;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;

  bool get hasMore => loadedCount < total;

  ProductListState copyWith({
    List<Product>? items,
    int? loadedCount,
    int? total,
    bool isLoadingMore = false,
    Failure? loadMoreFailure,
  }) {
    return ProductListState(
      items: items ?? this.items,
      loadedCount: loadedCount ?? this.loadedCount,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore,
      loadMoreFailure: loadMoreFailure,
    );
  }
}

class ProductListNotifier extends AsyncNotifier<ProductListState> {
  @override
  Future<ProductListState> build() async {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);

    final result = await ref.watch(productRepositoryProvider).getProducts(
          skip: 0,
          query: query,
          category: category,
        );

    return result.fold(
      (failure) => throw failure,
      (page) => ProductListState(
        items: page.items,
        loadedCount: page.requested,
        total: page.total,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    final query = ref.read(searchQueryProvider);
    final category = ref.read(selectedCategoryProvider);

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref.read(productRepositoryProvider).getProducts(
          skip: current.loadedCount,
          query: query,
          category: category,
        );

    final filtersChanged = query != ref.read(searchQueryProvider) ||
        category != ref.read(selectedCategoryProvider);
    if (filtersChanged) {
      return;
    }

    state = AsyncData(
      result.fold(
        (failure) => current.copyWith(loadMoreFailure: failure),
        (page) => current.copyWith(
          items: [...current.items, ...page.items],
          loadedCount: current.loadedCount + page.requested,
          total: page.total,
        ),
      ),
    );
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, ProductListState>(
  ProductListNotifier.new,
  retry: noRetry,
);
