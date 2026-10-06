import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/network_thumbnail.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/widgets/cart_badge_button.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../widgets/price_label.dart';
import '../widgets/rating_label.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: const [CartBadgeButton()],
      ),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorView(
          message: describeFailure(error),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (product) => _ProductDetail(product: product),
      ),
    );
  }
}

class _ProductDetail extends ConsumerWidget {
  const _ProductDetail({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(UiConstants.spacing * 2),
      children: [
        Center(
          child: NetworkThumbnail(
            url: product.thumbnail,
            width: double.infinity,
            height: UiConstants.detailImageHeight,
            borderRadius: 16,
          ),
        ),
        const SizedBox(height: UiConstants.spacing * 2),
        Text(product.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          product.brand ?? product.category,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: UiConstants.spacing),
        Row(
          children: [
            PriceLabel(product: product),
            const Spacer(),
            RatingLabel(rating: product.rating),
          ],
        ),
        const SizedBox(height: UiConstants.spacing),
        Text(
          product.isAvailable
              ? 'Disponible (${product.stock} en stock)'
              : 'Sin stock por ahora',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: UiConstants.spacing * 2),
        Text(product.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: UiConstants.spacing * 2),
        FilledButton.icon(
          onPressed: () => _addToCart(context, ref),
          icon: const Icon(Icons.add_shopping_cart_outlined),
          label: const Text('Agregar al carrito'),
        ),
      ],
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).add(product);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.title} se agregó al carrito'),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
