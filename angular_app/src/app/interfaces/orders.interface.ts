export interface CartProductDto {
  id: number;
  title: string;
  price: number;
  quantity: number;
  total: number;
  discountPercentage: number;
  discountedTotal: number;
  thumbnail: string;
}

export interface CartDto {
  id: number;
  userId: number;
  products: CartProductDto[];
  total: number;
  discountedTotal: number;
  totalProducts: number;
  totalQuantity: number;
}

export interface CartsResponseDto {
  carts: CartDto[];
  total: number;
}

export interface UserDto {
  id: number;
  firstName: string;
  lastName: string;
}

export interface UsersResponseDto {
  users: UserDto[];
}
