import { AsyncPipe, PercentPipe } from '@angular/common';
import { Component, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { map, switchMap } from 'rxjs';

import { toViewState } from '../../core/view-state';
import { MoneyPipe } from '../../shared/money.pipe';
import { StatusMessageComponent } from '../../shared/status-message/status-message.component';
import { OrdersService } from '../orders.service';

@Component({
  selector: 'app-order-detail-page',
  imports: [AsyncPipe, PercentPipe, MoneyPipe, RouterLink, StatusMessageComponent],
  templateUrl: './order-detail-page.component.html',
})
export class OrderDetailPageComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly ordersService = inject(OrdersService);

  protected readonly state$ = this.route.paramMap.pipe(
    map((params) => Number(params.get('id'))),
    switchMap((id) => this.ordersService.getOrder(id).pipe(toViewState())),
  );
}
