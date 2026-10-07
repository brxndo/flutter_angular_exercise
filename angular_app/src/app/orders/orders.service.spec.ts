import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { BASE_URL } from '../core/api';
import type { OrdersPage } from './order.models';
import { OrdersService } from './orders.service';

const cartsBody = {
  carts: [
    {
      id: 1,
      userId: 1,
      products: [
        {
          id: 162,
          title: 'Blue Frock',
          price: 29.99,
          quantity: 4,
          total: 119.96,
          discountPercentage: 12.13,
          discountedTotal: 105.41,
          thumbnail: 'https://cdn.dummyjson.com/blue-frock.webp',
        },
      ],
      total: 1000,
      discountedTotal: 900,
      totalProducts: 1,
      totalQuantity: 4,
    },
    {
      id: 2,
      userId: 2,
      products: [],
      total: 200,
      discountedTotal: 180,
      totalProducts: 0,
      totalQuantity: 0,
    },
  ],
  total: 208,
};

const usersBody = {
  users: [
    { id: 1, firstName: 'Emily', lastName: 'Johnson' },
    { id: 2, firstName: 'Michael', lastName: 'Williams' },
  ],
};

describe('OrdersService', () => {
  let service: OrdersService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });

    service = TestBed.inject(OrdersService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  function flushUsers(): void {
    http.expectOne((candidate) => candidate.url === `${BASE_URL}/users`).flush(usersBody);
  }

  it('la primera página pide limit 10 y skip 0 sobre /carts', () => {
    service.getOrders({ page: 1, userId: null, minTotal: null }).subscribe();

    const request = http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`);

    expect(request.request.params.get('limit')).toBe('10');
    expect(request.request.params.get('skip')).toBe('0');
    request.flush(cartsBody);
    flushUsers();
  });

  it('la página 3 avanza el skip a 20', () => {
    service.getOrders({ page: 3, userId: null, minTotal: null }).subscribe();

    const request = http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`);

    expect(request.request.params.get('skip')).toBe('20');
    request.flush(cartsBody);
    flushUsers();
  });

  it('el filtro por usuario cambia el endpoint', () => {
    service.getOrders({ page: 1, userId: 5, minTotal: null }).subscribe();

    const request = http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts/user/5`);

    expect(request.request.params.get('skip')).toBe('0');
    request.flush(cartsBody);
    flushUsers();
  });

  it('el catálogo de usuarios se pide una sola vez para toda la sesión', () => {
    service.getOrders({ page: 1, userId: null, minTotal: null }).subscribe();
    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    flushUsers();

    service.getOrders({ page: 2, userId: null, minTotal: null }).subscribe();
    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);

    http.expectNone((candidate) => candidate.url === `${BASE_URL}/users`);
  });

  it('mapea el DTO resolviendo el nombre y calculando ahorro y descuento', () => {
    let page: OrdersPage | undefined;
    service.getOrders({ page: 1, userId: null, minTotal: null }).subscribe((value) => {
      page = value;
    });

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    flushUsers();

    const order = page?.orders.at(0);

    expect(order?.id).toBe(1);
    expect(order?.userName).toBe('Emily Johnson');
    expect(order?.savings).toBe(100);
    expect(order?.discountRate).toBeCloseTo(0.1);
    expect(order?.products.at(0)?.title).toBe('Blue Frock');
  });

  it('un usuario que no está en el catálogo deja el nombre en null', () => {
    let page: OrdersPage | undefined;
    service.getOrders({ page: 1, userId: null, minTotal: null }).subscribe((value) => {
      page = value;
    });

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    http.expectOne((candidate) => candidate.url === `${BASE_URL}/users`).flush({ users: [] });

    expect(page?.orders.at(0)?.userName).toBeNull();
  });

  it('el total mínimo recorta los pedidos sin tocar el total del servidor', () => {
    let page: OrdersPage | undefined;
    service.getOrders({ page: 1, userId: null, minTotal: 500 }).subscribe((value) => {
      page = value;
    });

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    flushUsers();

    expect(page?.orders.map((order) => order.id)).toEqual([1]);
    expect(page?.fetched).toBe(2);
    expect(page?.total).toBe(208);
  });

  it('getOrder pide el carrito por id', () => {
    service.getOrder(7).subscribe();

    const request = http.expectOne(`${BASE_URL}/carts/7`);

    expect(request.request.method).toBe('GET');
    request.flush(cartsBody.carts[0]);
    flushUsers();
  });

  it('getUsers arma el nombre completo', () => {
    let users: { id: number; name: string }[] | undefined;
    service.getUsers().subscribe((value) => {
      users = value;
    });

    flushUsers();

    expect(users).toEqual([
      { id: 1, name: 'Emily Johnson' },
      { id: 2, name: 'Michael Williams' },
    ]);
  });
});
