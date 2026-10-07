**Dart y Flutter**

**1. ¿Qué diferencia hay entre final y const en Dart? ¿Por qué importa usar const en constructores de widgets?**

Son términos similares para declarar constantes, ya que el de const permite hacer que los valores ya se conozcan previamente antes de compilar, pero el final no, es decir el final se le puede asignar el valor a la variable una sola vez y ya no se puede modificar. Esto es importante ya que Flutter crea constantes de los widgets en la compilación y puede reutilizarlos en lugar de crearlos nuevamente y asi mejorar la eficiencia.

**2. Explica el null safety de Dart. ¿Cuándo usarías ? , ! , ?? y late ? ¿Por qué abusar de ! es una mala práctica?**

El null safety permite asegurarse de que al intentar acceder a un valor este no sea null.
El '?' se usaría para permitir el null como un estado válido. Ej: String? ciudad
El '!' se usaría para garantizar de que el valor de una variable no es null.
El '??' se usaría para establecer un valor alternativo por defecto en caso una variable sea null, ya que evalua una condicion ternaria.
El 'late' se lo utilizar para variables que se inicializarán despues. Normalmente se lo inicializa en el initstate.
El abuso de '!' es una mala práctica porque asume que un valor siempre va a tener un valor diferente de null, pero si esta suposición falla puede provocar excepciones al momento de la ejecución.

**3. ¿Cuál es la diferencia entre StatelessWidget y StatefulWidget ? ¿Qué aportan ConsumerWidget y ConsumerStatefulWidget ?**

El StatelessWidget es un widget que no maneja estados que varien con acciones del usuario y reciben informacion a traves de parametros, como por ejemplo widgets de Cards reutilizables. En cambio el StatefulWidget es un widget si maneja estados que altera la construcción del widget en tiempo de ejecución y permite actualizar la interfaz de forma automatica, como por ejemplo widget contador con un boton de accion.
El ConsumerWidget y ConsumerStatefulWidget no es mas que el poder acceder al valor del provider 'ref' de Riverpod en el StatelessWidget y StatefulWidget para poder interactuar con el y manejar estados.

**4. ¿Qué es un Future y qué es un Stream ? Da un caso de uso real de cada uno.**

Un Future representa una función asíncrona que retornará un único resultado o un error, en cambio un Stream representa varias funciones asíncronas las cuales devuelven un valor de forma consecutiva durante un pediodo de tiempo.

Un ejemplo de Future es una peticion HTTP hacia una API REST.
Un ejemplo de Stream son mensajes recibidos a traves de un Websocket, las cuales van llegando consecutivamente.

**5. ¿Por qué es preferible extraer un widget a una clase propia en lugar de un método _buildAlgo() que retorna un Widget ?**

Porque permite aislar las partes que realmente necesitan reconstruirse al momento de reconstrucción de widgets dentro del metodo build(), teniendo asi que cada widget pueda manejar su propio estado y ciclo de vida para una mejor optimización. Además al ser independientes, permiten la reutilización de widgets a lo largo de la gestión del proyecto.

**Riverpod**

**6. ¿Qué problema resuelve Riverpod frente a setState o frente a Provider (el paquete)?**

Riverpod permite gestionar los estados fuera del árbol de widgets, lo que permite que cualquier widget pueda acceder a los valores necesarios cuando lo deseen, en lugar de estar pasandolos por parámetros y hacer el llamado 'prop drilling' cuando solo se usa el 'setState'. Y frente a Provider es que al depender del context, los valores solo son accesibles en widgets, lo que limita bastante el alcance de este.

**7. Explica la diferencia entre ref.watch , ref.read y ref.listen . ¿Dónde es incorrecto usar ref.read ?**

'ref.watch' se usa para cuando se necesita que el widget se reconstruya al cambiar el valor del estado.
'ref.read' en cambio se usa para obtener los valores del estado pero sin que se reconstruya el widget.
'ref.listen' permite reaccionar a cambios ejecutando efectos secundarios como navegación, SnackBars o diálogos.

**8. ¿Cuándo usarías un Provider , un FutureProvider , un Notifier y un AsyncNotifier ?**

'Provider' se usaría cuando necesite exponer valores de forma síncrona cuando se obtiene de algun estado.
'FutureProvider' se usaría cuando necesito obtener información asíncrona.
'Notifier' se usaría cuando necesite encapsular la lógica de un estado para poder modificarlo.
'AsyncNotifier' se usaría para manejar lógica de negocio que involucra consultar asíncronas.

**9. ¿Qué hace el modificador autoDispose y qué problema evita? ¿Y family ?**

El 'autoDispose' permite eliminar el estado de un provider cuando no tiene listeners activos que esten pendientes de sus cambios y evita mantener estados activos y recursos innecesarios en memoria cuando dejan de usarse. El family permite crear estados parametrizados y se puede usar el autoDispose para eliminar el estado de cada estado automáticamente cuando ya no sean necesarios.

**10. ¿Cómo manejas los estados de carga, error y datos con AsyncValue ? Escribe un ejemplo con .when o pattern matching.**
Lo hace a traves metodos como .when() o coincidencia de patrones, los cuales permite gestionar cada estado de forma segura.

Ej:
```dart
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return usuariosAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
      data: (usuarios) {
        return ListView.builder(
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(usuarios[index].nombre),
            );
          },
        );
      },
    );
  }
```

**11. ¿Cómo sobrescribirías un provider en un test para inyectar un repositorio falso?**

Se utilizaría el overrides de Rivepod que reemplaze el provider del acceso a datos por un mock de datos hardcodeados, creando un acceso a datos falso, para que al acceder a este se puedan realizar las pruebas necesarias en lugar de de llamar a los servicios web.

**Angular**
**12. ¿Qué diferencia hay entre un componente standalone y uno declarado en un NgModule ?**

Los componentes standalone ya no se declara en un NgModule y por lo tanto obtiene todas sus dependencias mediante imports, por lo que es bastante reutilizable, ademas de que estos componentes son muy utiles para el lazy loading y reducen el boilerplate (codigo repetitivo).

**13. Explica la diferencia entre un Observable (RxJS) y un Signal. ¿Cuándo preferirías cada uno?**

Un Observable indica una secuencia de valores que puede llegar a lo largo del tiempo, similar al Stream de Flutter, ya que es utilizado en solicitudes HTTP, Websockets y eventos asincronos complejos; en cambio un Signal representa un valor reactivo (similar al estado) para alterar la interfaz de usuario en tiempo real.

**14. ¿Para qué sirven @Input() / input() y @Output() / output() ? ¿Cómo se comunican dos componentes hermanos?**

Ambos elementos son formas de comunición entre dos componentes padre e hijo, en donde los elementos 'input' sirven para pasar información de un componente padre hacia un componente hijo, a traves de un Signal. En cambio los elementos 'output' sirven para notificar al padre sobre cambios que ocurrieron en el componente hijo, a traves de evento como el emit().

**15. ¿Qué es la inyección de dependencias en Angular y para qué sirve providedIn:'root' ?**

La inyección de dependencia es una de las prácticas de la arquitectura limpia que permite crear dependencias, conectarlas y proporcionarlas cuando una clase necesita. Esto puede ser a traves del constructor o usando el inject(). Al declarar el 'providedIn:'root'' lo que hace que es el servicio/componente que se haya creado, se inyecte en la raiz de la aplicacion para permitir el uso en cualquier lugar.

**16. ¿Por qué hay que preocuparse por las suscripciones a Observables? Menciona dos formas de evitar fugas de memoria.**

Las suscripciones pueden seguir vivas aun cuando el componente que las activó hayan sido destruidos, lo qu epuede generar fugas de memoria en la aplicación y problemas de rendimiento o comportamiendo inesperados.
Una de las mejores opciones de evitar estos es usando el 'async' el cual permite desuscribirse automaticamente cuando se termine el proceso.
Otra manera sería a traves del metodo 'takeUntilDestroyed()' de RxJS, el cual provoca automáticamente la finalización de la suscripción al terminar de escuchar un observable.

**Código limpio y buenas prácticas**

**17. Explica con tus palabras el principio de responsabilidad única (SRP) y cómo lo aplicarías en una app Flutter**

El principio de responsabilidad unica indica que una clase debería gestionar solo las acciones que cumplan hacia un mismo propósito. Por ejemplo en una pantalla de Login se debe separar el acceso a datos, de la validacion, la persistencia de datos, de la navegación y con la de presentación, para no tener que modificar la interfaz en caso el acceso a datos tambien cambie; esto con el fin de tener un codigo limpio y mantenible.

**18. ¿Por qué separar la app en capas (presentación, dominio, datos)? ¿Qué va en cada una?**
Para que cada parte de la aplicación tenga su propia responsabilidad de forma concisa la cual afecte lo menos posible a las demás capas, ya que si no se restablece un orden al principio, cuando crece una aplicación, esta se puede volver dificil de mantener y probar.

**19. ¿Qué diferencia hay entre una prueba unitaria, una de widget y una de integración?**

En que todas depende sobre que parte aplicación de está probando y cuanto del sistema interviene, es decir una prueba unitaria valida funciones, clases, servicios, las cuales son mas rapidos de probar; en cambio la prueba de widget testea el comportamiento de un widget y su interacción para saber si todo funciona correctamente; y finalmente la prueba de integración, es una combinación de ambas ya que junta logica de negocio con interacción de la interfaz de usuario, como si fuera un flujo completo.

**20. Menciona tres convenciones que sigues al hacer commits y abrir un pull request.**

- Uso palabras clave como 'feature', 'fix', 'refactor' junto con mensajes cortos indicativos de las acciones realizadas.
- Intento que cada cambio sea commiteado y que refleje un valor de lo que se ha realizado.
- Reviso que todo este funcional, verificando la compilacion del codigo y que no existan errores o codigo innecesario.


---------------

**PARTE 4**

**Fragmento A — Flutter / Riverpod**

**1. La llamada a la API esta adentro del build()**

El build() se ejecuta cada vez que el widget se reconstruye, asi que cada respuesta llama a setState, setState vuelve a construir, y eso dispara otra llamada.


Lo sacaria del build y lo pondria en un FutureProvider, para que riverpod lo ejecute una sola vez y lo cachee.

**2. El carrito se modifica con add() sobre la lista que ya esta adentro del provider**

ref.read(cartProvider).add(p) agrega el producto a la misma lista de siempre. Riverpod compara el estado anterior con el nuevo para saber si tiene que avisar, y como es la misma lista no ve ningun cambio. El producto entra pero la pantalla no se entera.

En vez de modificar la lista crearia una nueva: state = [...state, product]. Y lo meteria en un Notifier con un metodo add(), asi la pantalla no sabe como se guarda.


**3. No hay tipos, solo hay List y Map**

p['title'] puede devolver cualquier cosa y a la app no le importa. Si la API renombra un campo o manda un numero donde habia texto, la app revienta recien cuando el usuario toca esa pantalla, y el error aparece lejos de donde esta el problema real.

Le armaria una clase Product con un fromJson que haga la conversion en un solo lugar. Si algo viene distinto, falla ahi y se entiende por que.

**4. Falta controlar el error por si la API falla**

No se revisa el codigo de respuesta ni se captura ningun error. Sin internet el usuario solo verias el CircularProgressIndicator simulando que se colgó la pagina.

El AsyncValue ya trae los tres estados y con .when() se dibuja carga, error y datos. En el error pondria el mensaje y un boton de reintentar.


**5. El ListView construye todos los productos de una sola**

Con .map().toList() se arman los 100 ListTile aunque entren 8 en pantalla, lo cual con este endpoint casi no se nota, pero si despues son 2000 productos, la app se tardaria en abrir.

Con ListView.builder construye solo lo que se ve.

**6. Mensaje de exito**

El print('agregado') no funciona en produccion y encima el usuario no recibe ninguna confirmacion de que el producto se agregó al carrito; esto lo cambiaria por un SnackBar.

**Fragmento B — Angular**

**1. El setInterval nunca se cancela**

Cuando el usuario sale de la pantalla el componente se destruye, pero el intervalo sigue vivo pidiendo a la API cada 5 segundos, es decir sii entra y sale diez veces quedan diez intervalos corriendo a la vez, cada uno escribiendo sobre un componente que ya no existe. Es una fuga de memoria y ademas gasto de datos.

Usaria el interval() de RxJS junto con takeUntilDestroyed(), que corta solo cuando el componente se va.

**2. El subscribe nunca se limpia**

Mismo problema que arriba pero con la suscripcion. Cada vuelta del intervalo abre una nueva y ninguna se cierra. Lo armaria como un solo stream y lo mostraria con el pipe async en el template, que se desuscribe solo.

**3. Pide de nuevo cada 5 segundos sin esperar a que termine la anterior**

Si la API tarda 6 segundos, la llamada nueva sale antes de que la anterior termine y las respuestas pueden llegar desordenadas, por lo que el usuario vería datos viejos sobre los nuevos.

Con switchMap la llamada anterior se cancela sola cuando arranca la siguiente.

**4. No hay datos tipados: orders: any y (r: any)**

El any es una mala practicas ya que Typescript no revisa si estos esta mal y lo pasa por alto..

Pondria un interface Order y tiparia la llamada: this.http.get<CartsResponse>(...).

**5. El componente llama a HttpClient directo**

No existe separacion de modulos, componente y servicios 

Lo moveria a un servicio con providedIn: 'root' y el componente solo lo pide.


**6. No hay estado de carga ni de error**

El problema es que los primeros 5 segundos la pantalla quedan en blanco, porque el intervalo recien dispara la primera llamada cuando se cumple el tiempo, pero si la llamada falla no se muestra nada.

Se pediría los datos en el metodo ngOnInit y mostraria un mensaje mientras carga y otro si algo falla.

**Fragmento A corregido**

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Product {
  const Product({required this.id, required this.title, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  final int id;
  final String title;
  final double price;
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));

  if (response.statusCode != 200) {
    throw Exception('El servidor respondió ${response.statusCode}');
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;

  return (body['products'] as List<dynamic>)
      .map((item) => Product.fromJson(item as Map<String, dynamic>))
      .toList();
});

class CartNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => const [];

  void add(Product product) => state = [...state, product];
}

final cartProvider = NotifierProvider<CartNotifier, List<Product>>(
  CartNotifier.new,
);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Productos (${cart.length})')),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          message: '$error',
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];

            return ListTile(
              title: Text(product.title),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              onTap: () => _addToCart(context, ref, product),
            );
          },
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, Product product) {
    ref.read(cartProvider.notifier).add(product);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('${product.title} agregado')));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
```

