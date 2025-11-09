// Package imports:
import 'package:dio/dio.dart';

class PaginationLimitErrorInterceptor extends Interceptor {
  const PaginationLimitErrorInterceptor({
    required this.detectionString,
    required this.returnedStatusCode,
    required this.detectionStatusCode,
  });

  final String detectionString;
  final int returnedStatusCode;
  final int detectionStatusCode;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == detectionStatusCode) {
      final data = response.data;

      if (_containsPaginationLimitError(data)) {
        final error = DioException(
          requestOptions: response.requestOptions,
          response: response.copyWith(statusCode: returnedStatusCode),
          type: DioExceptionType.badResponse,
          message: 'Pagination limit reached',
        );

        handler.reject(error);
        return;
      }
    }

    super.onResponse(response, handler);
  }

  bool _containsPaginationLimitError(dynamic data) => switch (data) {
    final String s => s.toLowerCase().contains(detectionString.toLowerCase()),
    _ => false,
  };
}

extension _ResponseCopyWith on Response {
  Response copyWith({
    int? statusCode,
    String? statusMessage,
    dynamic data,
    Map<String, dynamic>? extra,
  }) {
    return Response(
      data: data ?? this.data,
      requestOptions: requestOptions,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      isRedirect: isRedirect,
      redirects: redirects,
      extra: extra ?? this.extra,
      headers: headers,
    );
  }
}
