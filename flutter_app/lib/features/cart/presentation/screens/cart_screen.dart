import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyView(message: 'Todavía no agregaste productos')
          : SlidableAutoCloseBehavior(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return CartItemTile(key: ValueKey(item.productId), item: item);
                },
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CartSummary(
              products: cart.productCount,
              units: cart.totalQuantity,
              amount: cart.totalAmount,
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(cartProvider.notifier);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
          'Se van a quitar todos los productos del carrito. ¿Querés continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      notifier.clear();
    }
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.products,
    required this.units,
    required this.amount,
  });

  final int products;
  final int units;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacing * 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${pluralize(products, 'producto', 'productos')} · '
                '${pluralize(units, 'unidad', 'unidades')}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
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
