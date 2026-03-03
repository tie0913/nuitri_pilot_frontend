/*
 * Parent Class of all the Results 
 * E is Error
 * T is Result
 */
sealed class Result<E, T> {}

class OK<E, T> extends Result<E, T>{
  final T value;
  OK(this.value);
}

class Err<E, T> extends Result<E, T>{
  final E error;
  Err(this.error);
}

class Error{
  final String message;
  Error(this.message);
}

class BackendError extends Error{
  final int code;
  BackendError(this.code, super.message);
}

class AppError extends Error{
  AppError(super.message);
}

class NetworkErr extends Error {
  final int httpStatus;
  NetworkErr(this.httpStatus, super.message);
}

