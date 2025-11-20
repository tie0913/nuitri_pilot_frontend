import 'package:dio/dio.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart'; // 可选：设置 contentType 用
import 'package:path/path.dart' as p;

final connector = Dio(
  BaseOptions(
    //baseUrl: 'http://localhost:5007',
    baseUrl: 'http://10.0.2.2:5007',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 300),
  ),
);


/// 判断 body 里是否含有“需要 multipart”的值
bool _containsFile(dynamic v) {
  if (v is File || v is Uint8List || v is MultipartFile) return true;
  if (v is List) return v.any(_containsFile);
  return false;
}

/// 把 Map 转成可被 FormData.fromMap 接受的结构
dynamic _toFormFieldValue(dynamic v) {
  if (v is File) {
    final name = p.basename(v.path);
    // 这里假设你现在都传 webp，若不是可以按文件后缀判断
    return MultipartFile.fromFileSync(
      v.path,
      filename: name,
      contentType: MediaType('image', 'webp'),
    );
  } else if (v is Uint8List) {
    return MultipartFile.fromBytes(
      v,
      filename: 'upload.bin',
      // 按需改 contentType；如果你传的是 webp 字节：
      contentType: MediaType('image', 'webp'),
    );
  } else if (v is MultipartFile) {
    return v;
  } else if (v is List) {
    return v.map(_toFormFieldValue).toList();
  } else if (v is DateTime) {
    return v.toIso8601String();
  } else {
    return v; // String / num / bool / null
  }
}

FormData _formDataFromBody(Map<String, dynamic> body) {
  final map = <String, dynamic>{};
  body.forEach((k, v) => map[k] = _toFormFieldValue(v));
  return FormData.fromMap(map);
}

/*
 * post方法
 * 如果调用方在body里放了文件，那么就自动变为 表单提交
 * 否则就是使用application/json类型协议
 */
Future<InterfaceResult<dynamic>> post<T>(
  String path,
  Map<String, dynamic> body, {
  String? token,
}) async {
  try {
    final isMultipart = body.values.any(_containsFile);
    final data = isMultipart ? _formDataFromBody(body) : body;

    final resp = await connector.post(
      path,
      data: data,
      options: Options(
        headers: {if (token != null) 'Authorization': token},
        contentType: isMultipart ? 'multipart/form-data' : Headers.jsonContentType,
      ),
    );

    final env = ApiEnvelope<T>.fromJson(resp.data);

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


/*
 * Basic post method for networking
Future<InterfaceResult<dynamic>> post<T>(
  String path,
  Map<String, dynamic> body,
  {String? token}) async {
  try {
    final resp = await connector.post(
      path,
      data: body,
      options: Options(
        headers: {if (token != null) 'Authorization': token},
      ),
    );

    final env = ApiEnvelope<T>.fromJson(resp.data);
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
 */

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
    Map<String, dynamic> json
  ) {
    return ApiEnvelope(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      data: json['data'] 
    );
  }
}