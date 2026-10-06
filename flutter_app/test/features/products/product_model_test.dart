import 'dart:convert';

import 'package:flutter_app/features/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapea los campos que usa la app', () {
    final json = jsonDecode('''
      {
        "id": 1,
        "title": "Essence Mascara Lash Princess",
        "description": "Mascara de larga duración",
        "category": "beauty",
        "price": 9.99,
        "discountPercentage": 7.17,
        "rating": 4.94,
        "stock": 5,
        "brand": "Essence",
        "thumbnail": "https://cdn.dummyjson.com/thumbnail.webp"
      }
    ''') as Map<String, dynamic>;

    final product = ProductModel.fromJson(json);

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.category, 'beauty');
    expect(product.price, 9.99);
    expect(product.rating, 4.94);
    expect(product.stock, 5);
    expect(product.brand, 'Essence');
    expect(product.hasDiscount, isTrue);
    expect(product.isAvailable, isTrue);
  });

  test('tolera productos sin brand y sin descuento', () {
    final product = ProductModel.fromJson(const {
      'id': 2,
      'title': 'Producto sin marca',
      'description': 'Sin marca',
      'category': 'groceries',
      'price': 4,
      'rating': 3,
      'stock': 0,
      'thumbnail': 'https://cdn.dummyjson.com/2.webp',
    });

    expect(product.brand, isNull);
    expect(product.discountPercentage, 0);
    expect(product.hasDiscount, isFalse);
    expect(product.isAvailable, isFalse);
    expect(product.finalPrice, 4);
  });

  test('acepta enteros donde la API a veces manda decimales', () {
    final product = ProductModel.fromJson(const {
      'id': 3,
      'title': 'Precio entero',
      'description': '',
      'category': 'furniture',
      'price': 120,
      'discountPercentage': 50,
      'rating': 5,
      'stock': 2,
      'thumbnail': '',
    });

    expect(product.price, 120.0);
    expect(product.finalPrice, 60.0);
  });
}
