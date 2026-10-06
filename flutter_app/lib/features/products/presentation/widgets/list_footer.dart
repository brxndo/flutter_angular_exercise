import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../providers/product_list_notifier.dart';

class ListFooter extends ConsumerWidget {
  const ListFooter({required this.state, super.key});

  final ProductListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failure = state.loadMoreFailure;

    if (failure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: UiConstants.spacing),
        child: Column(
          children: [
            Text(failure.message, textAlign: TextAlign.center),
            TextButton(
              onPressed: ref.read(productListProvider.notifier).loadMore,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (!state.hasMore) {
      return const SizedBox(height: UiConstants.spacing);
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: UiConstants.spacing * 2),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
