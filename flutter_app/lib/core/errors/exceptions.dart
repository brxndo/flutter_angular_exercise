class ServerException implements Exception {
  const ServerException(this.statusCode);

  final int statusCode;
}

class ParsingException implements Exception {
  const ParsingException();
}
