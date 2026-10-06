import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../cart/presentation/widgets/cart_badge_button.dart';
import '../providers/product_list_notifier.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/list_footer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_field.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final reachedBottom =
        position.pixels >=
        position.maxScrollExtent - UiConstants.loadMoreOffset;

    if (reachedBottom) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catálogo de Productos'),
          actions: const [ThemeToggleButton(), CartBadgeButton()],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const ProductSearchField(),
              const SizedBox(height: UiConstants.spacing),
              const CategoryFilterBar(),
              Expanded(
                child: products.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => ErrorView(
                    message: describeFailure(error),
                    onRetry: () => ref.invalidate(productListProvider),
                  ),
                  data: (state) => _ProductList(
                    state: state,
                    scrollController: _scrollController,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  const _ProductList({required this.state, required this.scrollController});

  final ProductListState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.items.isEmpty) {
      return EmptyView(
        message: 'No encontramos productos con esos filtros',
        action: state.hasMore
            ? TextButton(
                onPressed: ref.read(productListProvider.notifier).loadMore,
                child: const Text('Cargar más'),
              )
            : null,
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(UiConstants.spacing),
      itemCount: state.items.length + 1,
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return ListFooter(state: state);
        }
        return ProductCard(product: state.items[index]);
      },
    );
  }
}
