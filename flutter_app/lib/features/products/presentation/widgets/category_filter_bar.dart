import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ui_constants.dart';
import '../providers/product_providers.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return categories.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (items) => SizedBox(
        height: UiConstants.categoryBarHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacing),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = items[index];
            return Center(
              child: FilterChip(
                label: Text(category.name),
                selected: selected == category.slug,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).toggle(category.slug),
              ),
            );
          },
        ),
      ),
    );
  }
}
