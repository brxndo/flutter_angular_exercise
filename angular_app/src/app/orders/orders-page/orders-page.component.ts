import { Component, computed, inject, signal } from '@angular/core';
import { toObservable, toSignal } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { catchError, of, switchMap } from 'rxjs';

import { toViewState, type ViewState } from '../../core/view-state';
import { StatusMessageComponent } from '../../shared/status-message/status-message.component';
import { OrderCardComponent } from '../order-card/order-card.component';
import type { OrdersFilter, OrdersPage, OrdersQuery, User } from '../order.models';
import { OrdersService } from '../orders.service';
import { OrdersFilterComponent } from '../orders-filter/orders-filter.component';
import { PaginatorComponent } from '../paginator/paginator.component';

const INITIAL_QUERY: OrdersQuery = { page: 1, userId: null, minTotal: null };

@Component({
  selector: 'app-orders-page',
  imports: [OrdersFilterComponent, OrderCardComponent, PaginatorComponent, StatusMessageComponent],
  templateUrl: './orders-page.component.html',
})
export class OrdersPageComponent {
  private readonly ordersService = inject(OrdersService);
  private readonly router = inject(Router);

  private readonly query = signal<OrdersQuery>(INITIAL_QUERY);

  protected readonly state = toSignal(
    toObservable(this.query).pipe(
      switchMap((query) => this.ordersService.getOrders(query).pipe(toViewState())),
    ),
    { initialValue: { status: 'loading' } as ViewState<OrdersPage> },
  );

  protected readonly users = toSignal(
    this.ordersService.getUsers().pipe(catchError(() => of<User[]>([]))),
    { initialValue: [] },
  );

  protected readonly currentPage = computed(() => this.query().page);

  protected readonly skeletons = Array.from({ length: 6 }, (_, index) => index);

  protected onFilterChange(filter: OrdersFilter): void {
    this.query.set({ page: 1, ...filter });
  }

  protected onPageChange(page: number): void {
    this.query.update((query) => ({ ...query, page }));
  }

  protected openDetail(orderId: number): void {
    void this.router.navigate(['/orders', orderId]);
  }

  protected reload(): void {
    this.query.update((query) => ({ ...query }));
  }
}
