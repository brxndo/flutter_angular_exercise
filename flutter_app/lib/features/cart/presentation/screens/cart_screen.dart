import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_view.dart';
import '../providers/cart_providers.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Vaciar carrito',
              icon: const Icon(Icons.remove_shopping_cart_outlined),
              onPressed: ref.read(cartProvider.notifier).clear,
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyView(message: 'Todavía no agregaste productos')
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) => CartItemTile(item: cart.items[index]),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CartSummary(quantity: cart.totalQuantity, amount: cart.totalAmount),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.quantity, required this.amount});

  final int quantity;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacing * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$quantity ${quantity == 1 ? 'producto' : 'productos'}'),
            Text(
              formatPrice(amount),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
