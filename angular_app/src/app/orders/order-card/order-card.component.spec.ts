import { inputBinding, outputBinding, signal } from '@angular/core';
import { TestBed } from '@angular/core/testing';

import type { Order } from '../order.models';
import { OrderCardComponent } from './order-card.component';

const order: Order = {
  id: 7,
  userId: 3,
  userName: 'Sophia Brown',
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
  savings: 100,
  discountRate: 0.1,
  totalProducts: 1,
  totalQuantity: 4,
};

function findButton(element: HTMLElement, label: string): HTMLButtonElement {
  const button = Array.from(element.querySelectorAll('button')).find((candidate) =>
    candidate.textContent?.includes(label),
  );

  if (button === undefined) {
    throw new Error(`No hay ningún botón con el texto "${label}"`);
  }

  return button;
}

describe('OrderCardComponent', () => {
  it('muestra el pedido, el nombre del usuario y los dos totales', async () => {
    const fixture = TestBed.createComponent(OrderCardComponent, {
      bindings: [inputBinding('order', signal(order))],
    });
    await fixture.whenStable();

    const text = (fixture.nativeElement as HTMLElement).textContent ?? '';

    expect(text).toContain('Pedido #7');
    expect(text).toContain('Sophia Brown');
    expect(text).toContain('$1,000.00');
    expect(text).toContain('$900.00');
    expect(text).toContain('-10%');
  });

  it('sin nombre conocido cae al id del usuario', async () => {
    const fixture = TestBed.createComponent(OrderCardComponent, {
      bindings: [inputBinding('order', signal({ ...order, userName: null }))],
    });
    await fixture.whenStable();

    expect((fixture.nativeElement as HTMLElement).textContent).toContain('Usuario #3');
  });

  it('emite viewDetail con el id del pedido', async () => {
    const emitted: number[] = [];
    const fixture = TestBed.createComponent(OrderCardComponent, {
      bindings: [
        inputBinding('order', signal(order)),
        outputBinding<number>('viewDetail', (id) => emitted.push(id)),
      ],
    });
    await fixture.whenStable();

    findButton(fixture.nativeElement as HTMLElement, 'Ver detalle').click();

    expect(emitted).toEqual([7]);
  });
});
