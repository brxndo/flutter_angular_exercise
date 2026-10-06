import 'package:flutter_app/core/errors/failure.dart';
import 'package:flutter_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

const _productsBody = '''
{
  "products": [
    {
      "id": 1,
      "title": "Essence Mascara",
      "description": "Mascara",
      "category": "beauty",
      "price": 9.99,
      "discountPercentage": 7.17,
      "rating": 4.94,
      "stock": 5,
      "thumbnail": "https://cdn.dummyjson.com/1.webp"
    },
    {
      "id": 2,
      "title": "Silla de madera",
      "description": "Silla",
      "category": "furniture",
      "price": 40,
      "discountPercentage": 0,
      "rating": 4.1,
      "stock": 10,
      "thumbnail": "https://cdn.dummyjson.com/2.webp"
    }
  ],
  "total": 194,
  "skip": 0,
  "limit": 20
}
''';

void main() {
  late MockHttpClient client;
  late ProductRepository repository;

  setUpAll(() => registerFallbackValue(Uri.parse('https://dummyjson.com')));

  setUp(() {
    client = MockHttpClient();
    repository = ProductRepositoryImpl(ProductRemoteDataSource(client));
  });

  void respondWith(String body, {int statusCode = 200}) {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(body, statusCode));
  }

  Uri capturedUri() => verify(() => client.get(captureAny())).captured.single as Uri;

  test('devuelve Right con la página parseada cuando el servidor responde 200', () async {
    respondWith(_productsBody);

    final result = await repository.getProducts(skip: 0, query: '', category: null);

    final page = result.getOrElse((failure) => throw failure);
    expect(page.items, hasLength(2));
    expect(page.items.first.title, 'Essence Mascara');
    expect(page.total, 194);
    expect(page.requested, 2);
  });

  test('pagina con limit y skip sobre el endpoint de listado', () async {
    respondWith(_productsBody);

    await repository.getProducts(skip: 40, query: '', category: null);

    final uri = capturedUri();
    expect(uri.path, '/products');
    expect(uri.queryParameters, {'limit': '20', 'skip': '40'});
  });

  test('usa el endpoint de búsqueda cuando hay texto', () async {
    respondWith(_productsBody);

    await repository.getProducts(skip: 0, query: 'phone', category: null);

    final uri = capturedUri();
    expect(uri.path, '/products/search');
    expect(uri.queryParameters['q'], 'phone');
  });

  test('filtra por categoría en cliente cuando se combina con la búsqueda', () async {
    respondWith(_productsBody);

    final result =
        await repository.getProducts(skip: 0, query: 'silla', category: 'furniture');

    final page = result.getOrElse((failure) => throw failure);
    expect(page.items.map((product) => product.id), [2]);
    expect(page.requested, 2);
    expect(page.total, 194);
  });

  test('devuelve Left con ServerFailure ante un 500', () async {
    respondWith('{}', statusCode: 500);

    final result = await repository.getProducts(skip: 0, query: '', category: null);

    expect(result.isLeft(), isTrue);
    final failure = result.getLeft().toNullable();
    expect(failure, isA<ServerFailure>());
    expect(failure?.message, contains('500'));
  });

  test('devuelve Left con NetworkFailure cuando no hay conexión', () async {
    when(() => client.get(any())).thenThrow(http.ClientException('offline'));

    final result = await repository.getProducts(skip: 0, query: '', category: null);

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });

  test('devuelve Left con ParsingFailure si el cuerpo no es el esperado', () async {
    respondWith('no es json');

    final result = await repository.getProducts(skip: 0, query: '', category: null);

    expect(result.getLeft().toNullable(), isA<ParsingFailure>());
  });

  test('obtiene el detalle por id', () async {
    respondWith('''
      {
        "id": 7,
        "title": "Producto 7",
        "description": "Detalle",
        "category": "beauty",
        "price": 12.5,
        "discountPercentage": 0,
        "rating": 4,
        "stock": 3,
        "thumbnail": "https://cdn.dummyjson.com/7.webp"
      }
    ''');

    final result = await repository.getProductById(7);

    expect(capturedUri().path, '/products/7');
    expect(result.getOrElse((failure) => throw failure).title, 'Producto 7');
  });

  test('obtiene las categorías disponibles', () async {
    respondWith('[{"slug":"beauty","name":"Beauty","url":"x"}]');

    final result = await repository.getCategories();

    final categories = result.getOrElse((failure) => throw failure);
    expect(categories.single.slug, 'beauty');
    expect(categories.single.name, 'Beauty');
  });
}
