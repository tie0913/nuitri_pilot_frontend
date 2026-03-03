import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart'; // 可选：设置 contentType 用
import 'package:path/path.dart' as p;

final connector = Dio(
  BaseOptions(
    // iPhone
    //baseUrl: 'http://localhost:5007',
    // Android
    baseUrl: 'http://10.0.2.2:5007',
    // Online
    //baseUrl: 'https://backend-production-aea9.up.railway.app',
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
Future<Result<Error, T>> post<T>(
  String path,
  Map<String, dynamic> body, {
  String? token,
  required T Function(dynamic json) decoder
}) async {
  try {
    final isMultipart = body.values.any(_containsFile);
    final data = isMultipart ? _formDataFromBody(body) : body;

    final timezone = await FlutterTimezone.getLocalTimezone();
    final resp = await connector.post(
      path,
      data: data,
      options: Options(
        headers: {
          if (token != null) 'Authorization': token,
          'X-Timezone':timezone.identifier
        },
        contentType: isMultipart ? 'multipart/form-data' : Headers.jsonContentType,
      ),
    );

    final env = ApiEnvelope<T>.fromJson(resp.data, decoder);

    if (env.success) {
      return OK(env.data!);
    } else {
      return Err(BackendError(env.code, env.message));
    }
  } on DioException catch (e) {
    return Err(mapDioError(e));
  } catch (e) {
    return Err(NetworkErr(500, "Unknown Server Error"));
  }
}

NetworkErr mapDioError(DioException e) {
  int? sc = e.response?.statusCode;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return NetworkErr(504, "Timeout");
  }

  if (e.type == DioExceptionType.connectionError) {
    return NetworkErr(505, "Cannot connect to the Server");
  }

  String errorMsg = switch (sc) {
    401 => "Unauthorized",
    403 => "Forbiden",
    404 => "Resources not Exist",
    422 => "Illegal Parameters",
    429 => "Too many times",
    != null && >= 500 => "Unknown Server Error",
    null|| int() => "Unknow Network Erro",
  };

  return NetworkErr(sc??500, errorMsg);
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
    this.data
  });


   factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) decoder,
  ) {
    final bool success = json['success'] ?? false;

    return ApiEnvelope<T>(
      success: success,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: success && json['data'] != null
          ? decoder(json['data'])
          : null,
    );
  }
}