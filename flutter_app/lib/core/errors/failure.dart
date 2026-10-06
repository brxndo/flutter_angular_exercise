class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

String describeFailure(Object error) =>
    error is Failure ? error.message : 'Ocurrió un error inesperado';
