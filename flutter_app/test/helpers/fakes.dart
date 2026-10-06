import 'package:flutter_app/core/errors/failure.dart';
import 'package:flutter_app/features/cart/domain/cart_storage.dart';
import 'package:flutter_app/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/entities/product_category.dart';
import 'package:flutter_app/features/products/domain/entities/products_page.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

Product buildProduct({
  required int id,
  String? title,
  String category = 'beauty',
  double price = 10,
  double discountPercentage = 0,
  double rating = 4.5,
  int stock = 7,
}) {
  return Product(
    id: id,
    title: title ?? 'Producto $id',
    description: 'Descripción del producto $id',
    category: category,
    price: price,
    discountPercentage: discountPercentage,
    rating: rating,
    stock: stock,
    thumbnail: '',
  );
}

class FakeCartStorage implements CartStorage {
  FakeCartStorage([this._items = const []]);

  List<CartItem> _items;

  List<CartItem> get saved => _items;

  @override
  List<CartItem> read() => _items;

  @override
  Future<void> save(List<CartItem> items) async => _items = items;
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    this.total = 0,
    this.pages = const {},
    this.detail,
    this.categories = const [],
    this.failure,
  });

  final int total;
  final Map<int, List<Product>> pages;
  final Product? detail;
  final List<ProductCategory> categories;

  Failure? failure;

  final List<int> requestedSkips = [];

  @override
  Future<Either<Failure, ProductsPage>> getProducts({
    required int skip,
    required String query,
    required String? category,
  }) async {
    requestedSkips.add(skip);

    final failure = this.failure;
    if (failure != null) {
      return Left(failure);
    }

    final items = pages[skip] ?? const <Product>[];
    return Right(ProductsPage(items: items, total: total, requested: items.length));
  }

  @override
  Future<Either<Failure, Product>> getProductById(int id) async {
    final failure = this.failure;
    if (failure != null) {
      return Left(failure);
    }
    return Right(detail ?? buildProduct(id: id));
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategories() async {
    final failure = this.failure;
    if (failure != null) {
      return Left(failure);
    }
    return Right(categories);
  }
}
