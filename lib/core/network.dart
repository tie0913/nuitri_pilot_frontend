import 'package:dio/dio.dart';

final connector = Dio(BaseOptions(
  baseUrl:'http://10.0.2.2:5007',
  connectTimeout: const Duration(seconds:8),
  receiveTimeout: const Duration(seconds: 12)
));

/*
 * Basic post method for networking
 */
Future<Result<T>> post<T>(String path, Map<String, dynamic> body, T Function(Object? json) fromJsonT, {String? token}) async {

  try{
    final resp = await connector.post(path, 
      data:body, 
      options: Options(headers: {if(token != null) 'Authorization':'Nearer $token'})
    );

    final env = ApiEnvelope<T>.fromJson(resp.data, fromJsonT);
    if(env.success){
      return Ok(value:env.data as T);
    }else{
      return Err(error: mapBizError(env));
    }
  }on DioException catch(e) {
    return Err(error: mapDioError(e));
  }catch(e){
    return Err(error:AppError(ErrorKind.unknown, message: "Unknown Error $e"));
  }
}

AppError mapBizError<T>(ApiEnvelope<T> env){
  return AppError(ErrorKind.business, message: env.message, bizCode: env.bizCode);
}

AppError mapDioError(DioException e) {
  final sc = e.response?.statusCode;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return AppError(ErrorKind.network, message: "Timeout");
  }

  if (e.type == DioExceptionType.connectionError) {
    return AppError(ErrorKind.network, message: "Cannot connect to the Server");
  }

  if (sc == 401) return AppError(ErrorKind.unauthorized, httpStatus: sc, message: "Unauthorized");
  if (sc == 403) return AppError(ErrorKind.forbidden, httpStatus: sc, message: "Forbiden");
  if (sc == 404) return AppError(ErrorKind.notFound, httpStatus: sc, message: "Resources not Exist");
  if (sc == 429) return AppError(ErrorKind.rateLimited, httpStatus: sc, message: "Too many times");
  if (sc == 422) return AppError(ErrorKind.validation, httpStatus: sc, message: "Illegal Parameters");
  if (sc != null && sc >= 500) return AppError(ErrorKind.server, httpStatus: sc, message: "Server Error");

  return AppError(ErrorKind.unknown,
      httpStatus: sc, message: e.message ?? "Unknown Network Error");
}


class ApiEnvelope<T>{
  final bool success;
  final int bizCode;
  final String message;
  final T? data;

  ApiEnvelope({
    required this.success,
    required this.bizCode,
    required this.message,
    required this.data
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT){
    return ApiEnvelope(
      success: json['success'], 
      bizCode: json['bizCode'], 
      message: json['message'], 
      data: json['data'] != null? fromJsonT(json['data']) : null);
  }
}

enum ErrorKind{network, unauthorized, forbidden, notFound, rateLimited, server, validation, business, unknown}

class AppError{
  final ErrorKind kind;
  final String message;
  final int? httpStatus;
  final int? bizCode;
  final String? i18nKey;
  const AppError(this.kind, {this.message="", this.httpStatus, this.bizCode, this.i18nKey});
}

sealed class Result<T>{
  const Result();
}

class Ok<T> extends Result<T>{
  final T value;
  const Ok({required this.value});
}

class Err<T> extends Result<T>{
  final AppError error;
  const Err({required this.error});
}

