import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/failure.dart';
import 'package:flutter_app/core/storage/preferences_provider.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter_app/features/products/presentation/providers/product_providers.dart';
import 'package:flutter_app/features/products/presentation/screens/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  Widget buildScreen(FakeProductRepository repository) {
    return ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(repository),
        cartStorageProvider.overrideWithValue(FakeCartStorage()),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MaterialApp(home: ProductsScreen()),
    );
  }

  testWidgets('muestra el listado con los productos que entrega el repositorio',
      (tester) async {
    await tester.pumpWidget(
      buildScreen(
        FakeProductRepository(
          total: 2,
          pages: {
            0: [
              buildProduct(id: 1, title: 'Mascara Essence'),
              buildProduct(id: 2, title: 'Silla de madera'),
            ],
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mascara Essence'), findsOneWidget);
    expect(find.text('Silla de madera'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('muestra el indicador de carga mientras llega la respuesta',
      (tester) async {
    await tester.pumpWidget(buildScreen(FakeProductRepository()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
  });

  testWidgets('muestra el error y reintenta la consulta al presionar el botón',
      (tester) async {
    final repository =
        FakeProductRepository(failure: const NetworkFailure('Sin conexión'));

    await tester.pumpWidget(buildScreen(repository));
    await tester.pump();

    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    repository.failure = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump();

    expect(repository.requestedSkips, [0, 0]);
    expect(find.text('Sin conexión'), findsNothing);
  });

  testWidgets('muestra el estado vacío cuando no hay resultados', (tester) async {
    await tester.pumpWidget(buildScreen(FakeProductRepository()));
    await tester.pump();

    expect(find.text('No encontramos productos con esos filtros'), findsOneWidget);
  });

  testWidgets('agregar al carrito actualiza el contador del AppBar', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        FakeProductRepository(
          total: 1,
          pages: {
            0: [buildProduct(id: 1, title: 'Mascara Essence')],
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.descendant(of: find.byType(Badge), matching: find.text('1')), findsNothing);

    await tester.tap(find.byTooltip('Agregar al carrito'));
    await tester.pump();

    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );
  });
}
