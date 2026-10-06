import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ProductsPage>> getProducts({
    required int skip,
    required String query,
    required String? category,
  }) {
    return _guard(
      () => _remoteDataSource.fetchProducts(
        skip: skip,
        query: query,
        category: category,
      ),
    );
  }

  @override
  Future<Either<Failure, Product>> getProductById(int id) {
    return _guard(() => _remoteDataSource.fetchProductById(id));
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategories() {
    return _guard(_remoteDataSource.fetchCategories);
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on ServerException catch (exception) {
      return Left(ServerFailure('El servidor respondió ${exception.statusCode}'));
    } on ParsingException {
      return Left(const ParsingFailure('No pudimos leer la respuesta del servidor'));
    } on TimeoutException {
      return Left(const NetworkFailure('La solicitud tardó demasiado'));
    } on http.ClientException {
      return Left(const NetworkFailure('Sin conexión con el servidor'));
    }
  }
}
