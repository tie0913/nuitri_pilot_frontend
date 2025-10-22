import 'package:dio/dio.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';

final connector = Dio(
  BaseOptions(
    //baseUrl: 'http://localhost:5007',
    baseUrl: 'http://10.0.2.2:5007',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ),
);

/*
 * Basic post method for networking
 */
Future<InterfaceResult<T>> post<T>(
  String path,
  Map<String, dynamic> body,
  T Function(Object? json) fromJsonT, {
  String? token,
}) async {
  try {
    final resp = await connector.post(
      path,
      data: body,
      options: Options(
        headers: {if (token != null) 'Authorization': '$token'},
      ),
    );

    final env = ApiEnvelope<T>.fromJson(resp.data, fromJsonT);
    /**
     * 这里意味着后端执行给出了结果，有错就是业务错误了
     * 所以逻辑出错了就返回业务错了，就返回业务错误。
     * 业务成功就返回业务成功结果同时带着结果对象
     */
    if (env.success) {
      return BizOk(env.data as T);
    } else {
      return mapBizError(env);
    }
  } on DioException catch (e) {
    return mapDioError(e);
  } catch (e) {
    return NetworkErr(ErrorKind.unknown, -1, "Unknown Error $e");
  }
}

BizErr<T> mapBizError<T>(ApiEnvelope<T> env) {
  return BizErr(env.code, env.message);
}

NetworkErr<T> mapDioError<T>(DioException e) {
  int? sc = e.response?.statusCode;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return NetworkErr(ErrorKind.network, sc, "Timeout");
  }

  if (e.type == DioExceptionType.connectionError) {
    return NetworkErr(ErrorKind.network, sc, "Cannot connect to the Server");
  }

  return switch (sc) {
    401 => NetworkErr(ErrorKind.unauthorized, sc, "Unauthorized"),
    403 => NetworkErr(ErrorKind.forbidden, sc, "Forbiden"),
    404 => NetworkErr(ErrorKind.notFound, sc, "Resources not Exist"),
    422 => NetworkErr(ErrorKind.validation, sc, "Illegal Parameters"),
    429 => NetworkErr(ErrorKind.rateLimited, sc, "Too many times"),
    != null && >= 500 => NetworkErr(ErrorKind.server, sc, "Server Error"),
    _ => NetworkErr(
      ErrorKind.unknown,
      sc,
      e.message ?? "Unknown Network Error",
    ),
  };
}

class ApiEnvelope<T> {
  final bool success;
  final int code;
  final String message;
  final T? data;

  ApiEnvelope({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiEnvelope(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}