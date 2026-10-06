import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/network_thumbnail.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_providers.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacing,
        vertical: 4,
      ),
      leading: NetworkThumbnail(url: item.thumbnail, width: 56, height: 56),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${formatPrice(item.price)} c/u'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Quitar uno',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => notifier.updateQuantity(item.productId, item.quantity - 1),
          ),
          Text('${item.quantity}'),
          IconButton(
            tooltip: 'Agregar uno',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => notifier.updateQuantity(item.productId, item.quantity + 1),
          ),
          IconButton(
            tooltip: 'Eliminar del carrito',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => notifier.remove(item.productId),
          ),
        ],
      ),
    );
  }
}
