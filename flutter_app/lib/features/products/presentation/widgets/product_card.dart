import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/widgets/network_thumbnail.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/product.dart';
import 'price_label.dart';
import 'rating_label.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isInCart = ref.watch(cartProvider.select((cart) => cart.contains(product.id)));

    return Card(
      margin: const EdgeInsets.only(bottom: UiConstants.spacing),
      color: isInCart ? theme.colorScheme.secondaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/product/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkThumbnail(
                url: product.thumbnail,
                width: UiConstants.cardImageSize,
                height: UiConstants.cardImageSize,
              ),
              const SizedBox(width: UiConstants.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    RatingLabel(rating: product.rating),
                    const SizedBox(height: 4),
                    PriceLabel(product: product),
                  ],
                ),
              ),
              IconButton(
                tooltip: isInCart ? 'Agregar otra unidad' : 'Agregar al carrito',
                icon: Icon(
                  isInCart ? Icons.shopping_cart : Icons.add_shopping_cart_outlined,
                ),
                onPressed: () => _addToCart(context, ref),
              ),
            ],
          ),
        ),
      ),
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
