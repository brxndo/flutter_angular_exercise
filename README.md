**Prueba técnica — Flutter + Angular**
**BRANDO TOLEDO**

**Cómo correr**

**flutter_app**

```bash
cd flutter_app
flutter pub get
flutter run
flutter test
```

**angular_app**

```bash
cd angular_app
npm install
ng serve
npx ng test --no-watch 
```

**Decisiones de arquitectura**

La idea en las dos apps es la misma, es decir la pantalla no sabe de donde salen los datos. Pide lo que necesita y alguien mas se encarga de ir a buscarlo. Eso es lo que permite que los tests reemplacen esa parte por datos falsos y no realicen la busqueda web.

En Flutter armé tres capas por feature (datos, dominio y presentación) porque la app tiene dos features que crecen: productos y carrito. El estado va con Riverpod, y los errores viajan como un tipo propio en lugar de excepciones sueltas, asi la pantalla siempre tiene algo concreto que mostrar.

En Angular no copie esa estructura. La app es una sola pantalla y media. Quedo un servicio que trae los datos, un componente contenedor que arma el estado, y componentes chicos que solo reciben algo y lo muestran.

Una cosa que hay que tomar en cuenta es que la API no siempre puede filtrar lo que uno quiere. En Flutter no se puede combinar busqueda con categoría, y en Angular no existe filtrar por monto minimo. En los dos casos el filtro que falta lo aplico del lado del cliente sobre la página que ya traje, y la pantalla avisa cuántos resultados escondió para no mentir con los números.

**Qué quedó pendiente**

- El filtro por monto minimo del panel mira solo la página actual, no los 208 pedidos. Para que fuera global habria que traer todo junto y paginar en el navegador, y ahí se pierde la paginación real contra la API.
- La app de Angular no tiene modo oscuro. La de Flutter si.
- El manejo de errores muestra un mensaje y un boton de reintentar, nada mas. No distingue entre "no hay internet" y "el servidor devolvio cualquier cosa" mas alla del texto.

**Qué mejoraría con más tiempo**

Lo primero seria guardar los filtros en la URL del panel. Actualmente si se filtra por un usuario y luego se le pasa el link a alguien, el otro abre la lista desde cero.

Despues le pondria paginación por scroll al carrito y a la tabla de productos del detalle, que hoy muestran todo junto. Con pedidos de pocos productos nno se nota mucho, pero no es escalable.

Y me gustaría unificar los textos en un solo lugar. Todos estan escritos directo en cada pantalla pero si mañana hay que traducir la app, hay que ir archivo por archivo.
