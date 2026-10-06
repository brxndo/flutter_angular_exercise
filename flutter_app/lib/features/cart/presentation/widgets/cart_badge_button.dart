import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_providers.dart';

class CartBadgeButton extends ConsumerWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(cartProvider.select((cart) => cart.totalQuantity));

    return IconButton(
      tooltip: 'Ver carrito',
      onPressed: () => context.push('/cart'),
      icon: Badge(
        isLabelVisible: quantity > 0,
        label: Text('$quantity'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
