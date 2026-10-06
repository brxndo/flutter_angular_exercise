import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  const productA = CartItem(
    productId: 1,
    title: 'Producto A',
    price: 10,
    thumbnail: '',
    quantity: 2,
  );
  const productB = CartItem(
    productId: 2,
    title: 'Producto B',
    price: 5,
    thumbnail: '',
    quantity: 1,
  );

  late FakeCartStorage storage;

  setUp(() => storage = FakeCartStorage([productA, productB]));

  Future<void> pumpCart(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cartStorageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: CartScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('ya no hay botón de eliminar en cada item', (tester) async {
    await pumpCart(tester);

    expect(find.byTooltip('Eliminar del carrito'), findsNothing);
    expect(find.byTooltip('Quitar uno'), findsNWidgets(2));
  });

  testWidgets('deslizar a la izquierda revela la acción de eliminar',
      (tester) async {
    await pumpCart(tester);

    expect(find.text('Eliminar'), findsNothing);

    await tester.drag(find.text('Producto A'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Producto A'), findsNothing);
    expect(find.text('Producto B'), findsOneWidget);
    expect(storage.saved.single.productId, 2);
  });

  testWidgets('abrir un item cierra el que estaba abierto', (tester) async {
    await pumpCart(tester);

    await tester.drag(find.text('Producto A'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Eliminar'), findsOneWidget);

    await tester.drag(find.text('Producto B'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar'), findsOneWidget);
  });

  testWidgets('vaciar el carrito pide confirmación y respeta el cancelar',
      (tester) async {
    await pumpCart(tester);

    await tester.tap(find.byTooltip('Vaciar carrito'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text('Se van a quitar todos los productos del carrito. ¿Querés continuar?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Producto A'), findsOneWidget);
    expect(storage.saved, hasLength(2));
  });

  testWidgets('confirmar el diálogo vacía el carrito', (tester) async {
    await pumpCart(tester);

    await tester.tap(find.byTooltip('Vaciar carrito'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vaciar'));
    await tester.pumpAndSettle();

    expect(find.text('Producto A'), findsNothing);
    expect(find.text('Todavía no agregaste productos'), findsOneWidget);
    expect(storage.saved, isEmpty);
  });

  testWidgets('el resumen distingue productos de unidades', (tester) async {
    await pumpCart(tester);

    expect(find.text('2 productos · 3 unidades'), findsOneWidget);
    expect(find.text('\$25.00'), findsOneWidget);
  });
}
