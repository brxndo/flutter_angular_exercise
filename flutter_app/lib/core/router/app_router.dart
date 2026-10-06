import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProductsScreen(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (context, state) => ProductDetailScreen(
            productId: int.parse(state.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
      ],
    ),
  ],
);
