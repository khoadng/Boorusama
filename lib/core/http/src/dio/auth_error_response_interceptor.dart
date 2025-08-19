// Package imports:
import 'package:dio/dio.dart';

class AuthErrorResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if response is successful but contains authentication error
    if (response.statusCode == 200) {
      final data = response.data;

      // Check if response data contains authentication error message
      if (_containsAuthenticationError(data)) {
        // Create a 401 error response
        final error = DioException(
          requestOptions: response.requestOptions,
          response: response.copyWith(statusCode: 401),
          type: DioExceptionType.badResponse,
          message: 'Authentication required',
        );

        handler.reject(error);
        return;
      }
    }

    super.onResponse(response, handler);
  }

  bool _containsAuthenticationError(dynamic data) {
    if (data == null) return false;

    // Check string responses
    if (data is String) {
      return data.toLowerCase().startsWith('missing authentication');
    }

    return false;
  }
}

extension _ResponseCopyWith on Response {
  Response copyWith({
    int? statusCode,
    String? statusMessage,
    dynamic data,
    Map<String, dynamic>? extra,
  }) {
    return Response(
      requestOptions: requestOptions,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      data: data ?? this.data,
      headers: headers,
      extra: extra ?? this.extra,
      redirects: redirects,
    );
  }
}
