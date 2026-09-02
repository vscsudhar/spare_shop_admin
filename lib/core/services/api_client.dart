import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'token_service.dart';

class ApiClient {
  late final Dio dio;
  final TokenService _tokenService;
  final Function()? onLogoutCallback;

  ApiClient({TokenService? tokenService, this.onLogoutCallback})
      : _tokenService = tokenService ?? locator<TokenService>() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final isAuthEndpoint =
            options.path.startsWith(ApiEndpoints.adminLogin) ||
                options.path.startsWith(ApiEndpoints.customerLogin) ||
                options.path.startsWith(ApiEndpoints.customerRegister);

        final token = await _tokenService.getAccessToken();
        if (token != null && token.isNotEmpty && !isAuthEndpoint) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          options.headers.remove('Authorization');
        }
        return handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          final requestOptions = err.requestOptions;

          if (requestOptions.path.contains(ApiEndpoints.refreshToken)) {
            await _handleLogout();
            return handler.next(err);
          }

          try {
            final refreshToken = await _tokenService.getRefreshToken();
            if (refreshToken == null) {
              await _handleLogout();
              return handler.next(err);
            }

            final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
            final response = await refreshDio.post(
              ApiEndpoints.refreshToken,
              data: {'refreshToken': refreshToken},
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = response.data['data'];
              final newAccessToken = data['accessToken'];
              final newRefreshToken = data['refreshToken'];

              await _tokenService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retriedResponse = await dio.fetch(requestOptions);
              return handler.resolve(retriedResponse);
            }
          } catch (e) {
            await _handleLogout();
            return handler.next(err);
          }
        }
        return handler.next(err);
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }

  Future<void> _handleLogout() async {
    await _tokenService.clearTokens();
    if (onLogoutCallback != null) {
      onLogoutCallback!();
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.get(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      return await dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      return await dio.patch(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      return await dio.put(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      return await dio.delete(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Connection timeout. Please verify your network.',
        statusCode: 408,
      );
    }

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        String? errorCode;
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty && errors[0] is Map) {
          errorCode = errors[0]['code']?.toString();
        }
        return ApiException(
          message: data['message'] ?? 'An error occurred.',
          statusCode: e.response!.statusCode,
          code: errorCode,
          errors: errors is List ? errors : null,
        );
      }
      return ApiException(
        message: 'HTTP error: ${e.response!.statusMessage}',
        statusCode: e.response!.statusCode,
      );
    }

    return ApiException(
      message: 'Network error. Please check your internet connection.',
      statusCode: 500,
    );
  }
}
