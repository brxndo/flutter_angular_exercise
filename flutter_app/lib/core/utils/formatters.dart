String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

String pluralize(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';
