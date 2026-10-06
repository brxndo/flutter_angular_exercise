import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

class PriceLabel extends StatelessWidget {
  const PriceLabel({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = Text(
      formatPrice(product.finalPrice),
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );

    if (!product.hasDiscount) {
      return price;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        price,
        const SizedBox(width: 6),
        Text(
          formatPrice(product.price),
          style: theme.textTheme.bodySmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
