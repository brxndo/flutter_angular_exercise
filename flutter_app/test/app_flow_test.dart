import 'package:flutter/material.dart';
import 'package:flutter_app/core/router/app_router.dart';
import 'package:flutter_app/core/storage/preferences_provider.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter_app/features/products/presentation/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('flujo completo: listado → detalle → agregar al carrito', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = FakeCartStorage();
    final product = buildProduct(id: 1, title: 'Mascara Essence', price: 20);

    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(total: 1, pages: {0: [product]}, detail: product),
          ),
          cartStorageProvider.overrideWithValue(storage),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Mascara Essence'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle'), findsOneWidget);
    expect(find.text('Disponible (7 en stock)'), findsOneWidget);

    await tester.tap(find.text('Agregar al carrito'));
    await tester.pump();

    expect(storage.saved.single.productId, 1);

    await tester.tap(find.byTooltip('Ver carrito'));
    await tester.pumpAndSettle();

    expect(find.text('Carrito'), findsOneWidget);
    expect(find.text('1 producto · 1 unidad'), findsOneWidget);
    expect(find.text('\$20.00'), findsOneWidget);
  });
}
