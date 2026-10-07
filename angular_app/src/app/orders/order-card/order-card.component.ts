import { PercentPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';

import { MoneyPipe } from '../../shared/money.pipe';
import type { Order } from '../order.models';

const PREVIEW_SIZE = 3;

@Component({
  selector: 'app-order-card',
  imports: [PercentPipe, MoneyPipe],
  templateUrl: './order-card.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OrderCardComponent {
  readonly order = input.required<Order>();

  readonly viewDetail = output<number>();

  protected readonly who = computed(() => {
    const order = this.order();
    return order.userName ?? `Usuario #${order.userId}`;
  });

  protected readonly preview = computed(() => this.order().products.slice(0, PREVIEW_SIZE));

  protected readonly hiddenProducts = computed(() =>
    Math.max(0, this.order().products.length - PREVIEW_SIZE),
  );
}
