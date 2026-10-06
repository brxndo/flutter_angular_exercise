import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../entities/products_page.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductsPage>> getProducts({
    required int skip,
    required String query,
    required String? category,
  });

  Future<Either<Failure, Product>> getProductById(int id);

  Future<Either<Failure, List<ProductCategory>>> getCategories();
}
