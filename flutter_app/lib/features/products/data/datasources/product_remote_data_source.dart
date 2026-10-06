import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/products_page.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._client);

  final http.Client _client;

  Future<ProductsPage> fetchProducts({
    required int skip,
    required String query,
    required String? category,
  }) async {
    final body = await _get(_buildProductsUri(skip: skip, query: query, category: category));
    try {
      final json = body as Map<String, dynamic>;
      final products = (json['products'] as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return ProductsPage(
        items: _applyCategoryFilter(products, query: query, category: category),
        total: json['total'] as int,
        requested: products.length,
      );
    } catch (_) {
      throw const ParsingException();
    }
  }

  Future<Product> fetchProductById(int id) async {
    final body = await _get(Uri.parse('${ApiConstants.baseUrl}/products/$id'));
    try {
      return ProductModel.fromJson(body as Map<String, dynamic>);
    } catch (_) {
      throw const ParsingException();
    }
  }

  Future<List<ProductCategory>> fetchCategories() async {
    final body = await _get(Uri.parse('${ApiConstants.baseUrl}/products/categories'));
    try {
      return (body as List<dynamic>)
          .map((item) => ProductCategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ParsingException();
    }
  }

  Future<dynamic> _get(Uri uri) async {
    final response = await _client.get(uri).timeout(ApiConstants.timeout);

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ParsingException();
    }
  }

  Uri _buildProductsUri({
    required int skip,
    required String query,
    required String? category,
  }) {
    final pagination = {'limit': '${ApiConstants.pageSize}', 'skip': '$skip'};

    if (query.isNotEmpty) {
      return Uri.parse('${ApiConstants.baseUrl}/products/search')
          .replace(queryParameters: {'q': query, ...pagination});
    }

    if (category != null) {
      return Uri.parse('${ApiConstants.baseUrl}/products/category/$category')
          .replace(queryParameters: pagination);
    }

    return Uri.parse('${ApiConstants.baseUrl}/products')
        .replace(queryParameters: pagination);
  }

  List<Product> _applyCategoryFilter(
    List<Product> products, {
    required String query,
    required String? category,
  }) {
    if (query.isEmpty || category == null) {
      return products;
    }
    return products.where((product) => product.category == category).toList();
  }
}
