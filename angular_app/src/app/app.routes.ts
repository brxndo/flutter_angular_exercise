import { Routes } from '@angular/router';

import { OrdersPageComponent } from './orders/orders-page/orders-page.component';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'orders' },
  { path: 'orders', component: OrdersPageComponent },
  {
    path: 'orders/:id',
    loadComponent: () =>
      import('./orders/order-detail-page/order-detail-page.component').then(
        (m) => m.OrderDetailPageComponent,
      ),
  },
  { path: '**', redirectTo: 'orders' },
];
