export interface OrderProduct {
  id: number;
  title: string;
  price: number;
  quantity: number;
  total: number;
  discountPercentage: number;
  discountedTotal: number;
  thumbnail: string;
}

export interface User {
  id: number;
  name: string;
}

export interface Order {
  id: number;
  userId: number;
  userName: string | null;
  products: OrderProduct[];
  total: number;
  discountedTotal: number;
  savings: number;
  discountRate: number;
  totalProducts: number;
  totalQuantity: number;
}

export interface OrdersPage {
  orders: Order[];
  total: number;
  fetched: number;
}

export interface OrdersFilter {
  userId: number | null;
  minTotal: number | null;
}

export interface OrdersQuery extends OrdersFilter {
  page: number;
}
