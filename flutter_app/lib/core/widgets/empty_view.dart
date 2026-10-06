import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({required this.message, this.action, super.key});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacing * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: UiConstants.spacing),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: UiConstants.spacing),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
