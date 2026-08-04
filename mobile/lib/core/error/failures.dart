abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = "A server error occurred."]);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = "No internet connection."]);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  UnknownFailure([super.message = "An unknown error occurred."]);
}
