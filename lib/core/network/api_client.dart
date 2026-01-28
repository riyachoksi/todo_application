import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../error/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final AppConfig config;

  ApiClient(this.config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: Duration(milliseconds: config.connectTimeout),
        receiveTimeout: Duration(milliseconds: config.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (config.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final exception = _handleError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
            ),
          );
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return ServerException(
          _getErrorMessage(error.response),
          statusCode: error.response?.statusCode,
          code: 'SERVER_ERROR',
        );
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled', code: 'CANCELLED');
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
          code: 'NO_INTERNET',
        );
      default:
        return NetworkException(
          'Network error occurred',
          code: 'NETWORK_ERROR',
        );
    }
  }

  String _getErrorMessage(Response? response) {
    if (response == null) return 'Unknown server error';
    
    try {
      if (response.data is Map) {
        return response.data['message'] ?? 
               response.data['error'] ?? 
               'Server error occurred';
      }
      return 'Server error occurred';
    } catch (e) {
      return 'Server error occurred';
    }
  }

  AppException _handleError(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }
    return _handleDioError(error);
  }
}
