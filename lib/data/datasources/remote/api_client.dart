import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../local/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

class ApiClient {
  ApiClient(SecureStorageService storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: receiveTimeoutSeconds),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(storage),
      ErrorInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint('[Dio] $o'),
        ),
    ]);
  }

  late final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
