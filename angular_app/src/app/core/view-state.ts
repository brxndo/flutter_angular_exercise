import { catchError, map, of, startWith, type OperatorFunction } from 'rxjs';

import { describeHttpError } from './http-error';

export type ViewState<T> =
  { status: 'loading' } | { status: 'error'; message: string } | { status: 'ready'; data: T };

export function toViewState<T>(): OperatorFunction<T, ViewState<T>> {
  return (source) =>
    source.pipe(
      map((data): ViewState<T> => ({ status: 'ready', data })),
      startWith<ViewState<T>>({ status: 'loading' }),
      catchError((error: unknown) =>
        of<ViewState<T>>({ status: 'error', message: describeHttpError(error) }),
      ),
    );
}
