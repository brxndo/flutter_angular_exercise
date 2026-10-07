import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { forkJoin, map, shareReplay, type Observable } from 'rxjs';

import { BASE_URL, PAGE_SIZE } from '../core/api';
import type { Order, OrderProduct, OrdersPage, OrdersQuery, User } from './order.models';
import {
  CartDto,
  CartProductDto,
  CartsResponseDto,
  UserDto,
  UsersResponseDto,
} from '../interfaces/orders.interface';

const USERS_PARAMS = { limit: 0, select: 'id,firstName,lastName' };

@Injectable({ providedIn: 'root' })
export class OrdersService {
  private readonly http = inject(HttpClient);

  private readonly users$ = this.http
    .get<UsersResponseDto>(`${BASE_URL}/users`, { params: USERS_PARAMS })
    .pipe(
      map((response) => response.users.map(toUser)),
      shareReplay({ bufferSize: 1, refCount: true }),
    );

  getUsers(): Observable<User[]> {
    return this.users$;
  }

  getOrders(query: OrdersQuery): Observable<OrdersPage> {
    const url =
      query.userId === null ? `${BASE_URL}/carts` : `${BASE_URL}/carts/user/${query.userId}`;
    const params = { limit: PAGE_SIZE, skip: (query.page - 1) * PAGE_SIZE };

    return forkJoin([this.http.get<CartsResponseDto>(url, { params }), this.users$]).pipe(
      map(([response, users]) => {
        const names = toNames(users);
        const orders = response.carts.map((cart) => toOrder(cart, names));

        return {
          orders: orders.filter((order) => reachesMinTotal(order, query.minTotal)),
          total: response.total,
          fetched: orders.length,
        };
      }),
    );
  }

  getOrder(id: number): Observable<Order> {
    return forkJoin([this.http.get<CartDto>(`${BASE_URL}/carts/${id}`), this.users$]).pipe(
      map(([cart, users]) => toOrder(cart, toNames(users))),
    );
  }
}

function toUser(dto: UserDto): User {
  return { id: dto.id, name: `${dto.firstName} ${dto.lastName}` };
}

function toNames(users: User[]): ReadonlyMap<number, string> {
  return new Map(users.map((user) => [user.id, user.name]));
}

function toOrder(dto: CartDto, names: ReadonlyMap<number, string>): Order {
  const savings = dto.total - dto.discountedTotal;

  return {
    id: dto.id,
    userId: dto.userId,
    userName: names.get(dto.userId) ?? null,
    products: dto.products.map(toOrderProduct),
    total: dto.total,
    discountedTotal: dto.discountedTotal,
    savings,
    discountRate: dto.total === 0 ? 0 : savings / dto.total,
    totalProducts: dto.totalProducts,
    totalQuantity: dto.totalQuantity,
  };
}

function toOrderProduct(dto: CartProductDto): OrderProduct {
  return {
    id: dto.id,
    title: dto.title,
    price: dto.price,
    quantity: dto.quantity,
    total: dto.total,
    discountPercentage: dto.discountPercentage,
    discountedTotal: dto.discountedTotal,
    thumbnail: dto.thumbnail,
  };
}

function reachesMinTotal(order: Order, minTotal: number | null): boolean {
  return minTotal === null ? true : order.total >= minTotal;
}
