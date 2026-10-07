import { HttpErrorResponse } from '@angular/common/http';

export function describeHttpError(error: unknown): string {
  if (!(error instanceof HttpErrorResponse)) {
    return 'Ocurrió un error inesperado';
  }

  if (error.status === 0) {
    return 'Sin conexión con el servidor';
  }

  if (error.status === 404) {
    return 'No encontramos ese pedido';
  }

  return `El servidor respondió ${error.status}`;
}
