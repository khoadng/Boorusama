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
}) {
  return AutoRefreshAuthInterceptor(
    config: const AutoRefreshAuthConfig(
      cookieName: 'access_token',
    ),
    baseUrl: baseUrl,
    refreshToken: refreshToken,
    onRefresh: (currentRefreshToken) async {
      try {
        final client = EShuushuuClient(
          dio: Dio(BaseOptions(baseUrl: baseUrl)),
        );

        final tokens = await client.refresh(
          refreshToken: currentRefreshToken,
        );
        if (tokens == null) return null;

        return AuthTokenPair(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresInSeconds: tokens.expiresIn,
        );
      } catch (_) {
        return null;
      }
    },
    onTokenRefreshed: onTokenRefreshed,
  );
}
