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
    /**
     * 这里意味着后端执行给出了结果，有错就是业务错误了
     * 所以逻辑出错了就返回业务错了，就返回业务错误。
     * 业务成功就返回业务成功结果同时带着结果对象
     */
    if(env.success){
      return BizOk(value:env.data as T);
    }else{
      return mapBizError(env);
    }
  }on DioException catch(e) {
    return mapDioError(e);
  }catch(e){
    return Err(ErrorKind.unknown, -1, "Unknown Error $e");
  }
}

BizErr<T> mapBizError<T>(ApiEnvelope<T> env){
  return BizErr(env.code, env.message);
}

Err<T> mapDioError<T>(DioException e) {
  final sc = e.response?.statusCode;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return Err(ErrorKind.network, sc, "Timeout");
  }

  if (e.type == DioExceptionType.connectionError) {
    return Err(ErrorKind.network, sc, "Cannot connect to the Server");
  }

  if (sc == 401) return Err(ErrorKind.unauthorized, sc, "Unauthorized");
  if (sc == 403) return Err(ErrorKind.forbidden, sc, "Forbiden");
  if (sc == 404) return Err(ErrorKind.notFound, sc, "Resources not Exist");
  if (sc == 429) return Err(ErrorKind.rateLimited, sc, "Too many times");
  if (sc == 422) return Err(ErrorKind.validation, sc, "Illegal Parameters");
  if (sc != null && sc >= 500) return Err(ErrorKind.server, sc, "Server Error");

  return Err(ErrorKind.unknown,
      sc,  e.message ?? "Unknown Network Error");
}


class ApiEnvelope<T>{
  final bool success;
  final int code;
  final String message;
  final T? data;

  ApiEnvelope({
    required this.success,
    required this.code,
    required this.message,
    required this.data
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT){
    return ApiEnvelope(
      success: json['success'], 
      code: json['code'], 
      message: json['message'], 
      data: json['data'] != null? fromJsonT(json['data']) : null);
  }
}

enum ErrorKind{network, unauthorized, forbidden, notFound, rateLimited, server, validation, business, unknown}

sealed class Result<T>{
  const Result();
}

class BizResult<T> extends Result<T>{
  const BizResult();
}

class BizOk<T> extends BizResult<T>{
  final T value;
  const BizOk({required this.value});
}

class BizErr<T> extends BizResult<T>{
  final int code;
  final String message;
  const BizErr(this.code, this.message);
}

class Err<T> extends Result<T>{
  final ErrorKind kind;
  final int? httpStatus;
  final String message;
  const Err(this.kind, this.httpStatus, this.message);
}

