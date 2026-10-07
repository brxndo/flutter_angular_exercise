import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { BASE_URL } from '../../core/api';
import { OrdersPageComponent } from './orders-page.component';

const cartsBody = {
  carts: [
    {
      id: 1,
      userId: 1,
      products: [],
      total: 1000,
      discountedTotal: 900,
      totalProducts: 0,
      totalQuantity: 0,
    },
  ],
  total: 208,
};

const usersBody = { users: [{ id: 1, firstName: 'Emily', lastName: 'Johnson' }] };

function findButton(element: HTMLElement, label: string): HTMLButtonElement {
  const button = Array.from(element.querySelectorAll('button')).find((candidate) =>
    candidate.textContent?.includes(label),
  );

  if (button === undefined) {
    throw new Error(`No hay ningún botón con el texto "${label}"`);
  }

  return button;
}

describe('OrdersPageComponent', () => {
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting(), provideRouter([])],
    });

    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify({ ignoreCancelled: true }));

  it('muestra los esqueletos mientras espera la primera página', async () => {
    const fixture = TestBed.createComponent(OrdersPageComponent);
    await fixture.whenStable();

    const element = fixture.nativeElement as HTMLElement;

    expect(element.querySelectorAll('.animate-pulse')).toHaveLength(6);
    expect(element.querySelectorAll('app-order-card')).toHaveLength(0);

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    http
      .match((candidate) => candidate.url === `${BASE_URL}/users`)
      .forEach((request) => {
        request.flush(usersBody);
      });
  });

  it('reemplaza los esqueletos por las tarjetas cuando llega la respuesta', async () => {
    const fixture = TestBed.createComponent(OrdersPageComponent);
    await fixture.whenStable();

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    http.expectOne((candidate) => candidate.url === `${BASE_URL}/users`).flush(usersBody);
    await fixture.whenStable();

    const element = fixture.nativeElement as HTMLElement;

    expect(element.querySelectorAll('app-order-card')).toHaveLength(1);
    expect(element.textContent).toContain('Pedido #1');
    expect(element.textContent).toContain('Emily Johnson');
    expect(element.textContent).toContain('Mostrando 1-10 de 208 pedidos');
  });

  it('el selector se llena con los usuarios del catálogo', async () => {
    const fixture = TestBed.createComponent(OrdersPageComponent);
    await fixture.whenStable();

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    http.expectOne((candidate) => candidate.url === `${BASE_URL}/users`).flush(usersBody);
    await fixture.whenStable();

    const options = (fixture.nativeElement as HTMLElement).querySelectorAll('select option');

    expect(Array.from(options).map((option) => option.textContent?.trim())).toEqual([
      'Todos',
      'Emily Johnson',
    ]);
  });

  it('ante un error muestra el mensaje y Reintentar vuelve a pedir', async () => {
    const fixture = TestBed.createComponent(OrdersPageComponent);
    await fixture.whenStable();

    http
      .expectOne((candidate) => candidate.url === `${BASE_URL}/carts`)
      .flush('', { status: 500, statusText: 'Server Error' });
    await fixture.whenStable();

    const element = fixture.nativeElement as HTMLElement;

    expect(element.textContent).toContain('El servidor respondió 500');

    findButton(element, 'Reintentar').click();
    await fixture.whenStable();

    http.expectOne((candidate) => candidate.url === `${BASE_URL}/carts`).flush(cartsBody);
    http
      .match((candidate) => candidate.url === `${BASE_URL}/users`)
      .forEach((request) => {
        request.flush(usersBody);
      });
    await fixture.whenStable();

    expect(element.textContent).toContain('Pedido #1');
  });
});
