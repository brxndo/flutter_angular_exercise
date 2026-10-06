import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/network/http_providers.dart';
import '../../../../core/network/retry_policy.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ProductRemoteDataSource(ref.watch(httpClientProvider));
  return ProductRepositoryImpl(dataSource);
});

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  void onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(UiConstants.searchDebounce, () => state = value.trim());
  }

  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void toggle(String slug) => state = state == slug ? null : slug;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(SelectedCategoryNotifier.new);

final categoriesProvider = FutureProvider<List<ProductCategory>>(
  (ref) async {
    final result = await ref.watch(productRepositoryProvider).getCategories();
    return result.fold((failure) => throw failure, (categories) => categories);
  },
  retry: noRetry,
);

final productDetailProvider = FutureProvider.autoDispose.family<Product, int>(
  (ref, id) async {
    final result = await ref.watch(productRepositoryProvider).getProductById(id);
    return result.fold((failure) => throw failure, (product) => product);
  },
  retry: noRetry,
);
