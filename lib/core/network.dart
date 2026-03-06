import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import 'package:nuitri_pilot_frontend/core/common_result.dart';

String _resolveBaseUrl() {
  const envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (envBaseUrl.isNotEmpty) return envBaseUrl;

  // Emulator-only default for local development.
  return 'http://10.0.2.2:8000';
}

final connector = Dio(
  BaseOptions(
    baseUrl: _resolveBaseUrl(),

    connectTimeout: const Duration(seconds: 8),
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 300),

    responseType: ResponseType.json,
  ),
);

/// Check if any value in body requires multipart
bool _containsFile(dynamic v) {
  if (v is File || v is Uint8List || v is MultipartFile) return true;
  if (v is List) return v.any(_containsFile);
  return false;
}

/// Detect MIME from file extension
MediaType? _mimeFromPath(String path) {
  final ext = p.extension(path).toLowerCase();
  if (ext == '.jpg' || ext == '.jpeg') return MediaType('image', 'jpeg');
  if (ext == '.png') return MediaType('image', 'png');
  if (ext == '.webp') return MediaType('image', 'webp');
  return null; // unknown -> Dio will still send it
}

/// Convert Map values into FormData-compatible values
dynamic _toFormFieldValue(dynamic v) {
  if (v is File) {
    final name = p.basename(v.path);
    return MultipartFile.fromFileSync(
      v.path,
      filename: name,
      contentType: _mimeFromPath(v.path),
    );
  } else if (v is Uint8List) {
    return MultipartFile.fromBytes(
      v,
      filename: 'upload.bin',
      contentType: MediaType('application', 'octet-stream'),
    );
  } else if (v is MultipartFile) {
    return v;
  } else if (v is List) {
    return v.map(_toFormFieldValue).toList();
  } else if (v is DateTime) {
    return v.toIso8601String();
  } else {
    return v;
  }
}

FormData _formDataFromBody(Map<String, dynamic> body) {
  final map = <String, dynamic>{};
  body.forEach((k, v) => map[k] = _toFormFieldValue(v));
  return FormData.fromMap(map);
}

/// POST helper:
/// - If body contains File/Uint8List -> multipart FormData
/// - Otherwise -> JSON
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
        headers: {
          if (token != null) 'Authorization': token,
          // If your backend expects Bearer tokens instead, change to:
          // if (token != null) 'Authorization': 'Bearer $token',
        },

        // CRITICAL FIX:
        // Do NOT force 'multipart/form-data' or you lose the boundary.
        // Let Dio set the boundary automatically.
        contentType: isMultipart ? null : Headers.jsonContentType,

        // Don't throw for non-200; we want to parse response envelope.
        validateStatus: (_) => true,
      ),
    );

    // Dio may return Map or String depending on backend / headers
    final dynamic raw = resp.data;
    final Map<String, dynamic> json = raw is Map<String, dynamic>
        ? raw
        : (raw is String
              ? (jsonDecode(raw) as Map<String, dynamic>)
              : <String, dynamic>{});

    final env = ApiEnvelope<T>.fromJson(json);

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

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    return ApiEnvelope(
      success: json['success'] == true,
      code: json['code'] is int
          ? json['code']
          : int.tryParse('${json['code']}') ?? -1,
      message: json['message']?.toString() ?? '',
      data: json['data'] as T?,
    );
  }
}
