// Package imports:
import 'package:dio/dio.dart';

class DanbooruAuthInterceptor extends Interceptor {
  DanbooruAuthInterceptor({
    required this.login,
    required this.apiKey,
  });

  final String login;
  final String apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (login.isEmpty || apiKey.isEmpty) {
      handler.next(options);
      return;
    }

    options.queryParameters['login'] = login;
    options.queryParameters['api_key'] = apiKey;
    handler.next(options);
  }
}
