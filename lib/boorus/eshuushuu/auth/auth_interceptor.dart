// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../../../core/http/client/types.dart';

/// Creates an [AutoRefreshAuthInterceptor] configured for e-shuushuu's
/// cookie-based JWT auth.
AutoRefreshAuthInterceptor createEshuushuuAuthInterceptor({
  required String refreshToken,
  required String baseUrl,
  void Function(AuthTokenPair tokens)? onTokenRefreshed,
  void Function()? onAuthFailed,
  void Function(String message)? onLog,
}) {
  return AutoRefreshAuthInterceptor(
    config: const AutoRefreshAuthConfig(
      cookieName: 'access_token',
    ),
    baseUrl: baseUrl,
    refreshToken: refreshToken,
    onLog: onLog,
    onAuthFailed: onAuthFailed,
    onRefresh: (currentRefreshToken) async {
      try {
        final client = EShuushuuClient(
          dio: Dio(BaseOptions(baseUrl: baseUrl)),
        );

        final tokens = await client.refresh(
          refreshToken: currentRefreshToken,
        );
        if (tokens == null) {
          onLog?.call('Refresh response had no tokens (missing set-cookie?)');
          return null;
        }

        return AuthTokenPair(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresInSeconds: tokens.expiresIn,
        );
      } catch (e) {
        onLog?.call('Refresh request failed: $e');
        return null;
      }
    },
    onTokenRefreshed: onTokenRefreshed,
  );
}
