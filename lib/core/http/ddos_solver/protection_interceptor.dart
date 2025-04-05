// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../http.dart';
import '../src/cloudflare_challenge_interceptor.dart';
import 'protection_orchestrator.dart';
import 'protection_setup.dart';

class ProtectionInterceptor extends Interceptor {
  ProtectionInterceptor({
    required ProtectionOrchestrator orchestrator,
    required BuildContext Function() contextProvider,
    required UserAgentProvider userAgentProvider,
    required CookieJar cookieJar,
    required Dio dio,
    this.maxRetries = 3,
  })  : _orchestrator = orchestrator,
        _dio = dio,
        _cookieJar = cookieJar,
        _userAgentProvider = userAgentProvider,
        _contextProvider = contextProvider;
  final ProtectionOrchestrator _orchestrator;
  final UserAgentProvider _userAgentProvider;
  final CookieJar _cookieJar;
  final Dio _dio;
  final BuildContext Function() _contextProvider;

  // Track retry attempts
  final Map<String, int> _retryAttempts = {};
  final int maxRetries;
  bool _disable = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_disable) {
      return super.onRequest(options, handler);
    }

    try {
      final cookies = await _cookieJar.loadForRequest(options.uri);

      if (cookies.isNotEmpty) {
        final userAgent = await _userAgentProvider.getUserAgent();

        if (userAgent == null) {
          _disable = true;
          return super.onRequest(options, handler);
        }

        options.headers.addAll({
          AppHttpHeaders.cookieHeader: cookies.cookieString,
          AppHttpHeaders.userAgentHeader: userAgent,
        });
      }
    } catch (e) {
      _disable = true;
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Skip if disabled
    if (_disable) {
      return super.onResponse(response, handler);
    }

    try {
      final isProtection = await _orchestrator.handleResponse(response);

      if (isProtection) {
        // Clone request options for retry
        final options = response.requestOptions;
        final retryResponse = await _dio.fetch(options);
        handler.next(retryResponse);
        return;
      }
    } catch (e) {
      // Continue with normal response if handling fails
    }

    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final uriString = err.requestOptions.uri.toString();
    final retryCount = _retryAttempts[uriString] ?? 0;

    if (retryCount >= maxRetries) {
      _retryAttempts.remove(uriString);
      return handler.next(err);
    }

    try {
      // Get current context
      final context = _contextProvider();

      // Try to handle the protection
      final solved = await _orchestrator.handleError(context, err);

      if (solved) {
        // Challenge solved, retry the request
        _retryAttempts[uriString] = retryCount + 1;

        final options = err.requestOptions;

        // Copy all original request options
        final response = await _dio.fetch(options);
        handler.resolve(response);
        return;
      }
    } catch (e) {
      // If handling fails, continue with the error
    }

    return handler.next(err);
  }
}
