// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';

/// Auth token pair returned by a refresh operation.
class AuthTokenPair {
  const AuthTokenPair({
    required this.accessToken,
    required this.refreshToken,
    this.expiresInSeconds,
  });

  final String accessToken;
  final String refreshToken;
  final int? expiresInSeconds;
}

/// Configuration for [AutoRefreshAuthInterceptor].
class AutoRefreshAuthConfig {
  const AutoRefreshAuthConfig({
    required this.cookieName,
    this.defaultExpiresInSeconds = 600,
    this.refreshBufferSeconds = 60,
  });

  /// The cookie name used to transport the access token.
  final String cookieName;

  /// Default token lifetime when the server doesn't provide one.
  final int defaultExpiresInSeconds;

  /// Seconds before expiry to trigger a proactive refresh.
  final int refreshBufferSeconds;
}

/// A Dio interceptor that manages cookie-based JWT auth with proactive refresh.
///
/// - Injects the access token cookie on every request
/// - Proactively refreshes the token before it expires
/// - Retries failed 401 requests after a refresh
/// - Prevents concurrent refresh attempts
class AutoRefreshAuthInterceptor extends Interceptor {
  AutoRefreshAuthInterceptor({
    required this.config,
    required this.baseUrl,
    required Future<AuthTokenPair?> Function(String refreshToken) onRefresh,
    this.onTokenRefreshed,
    this.onAuthFailed,
    this.onLog,
    required String refreshToken,
  }) : _refreshToken = refreshToken,
       _onRefresh = onRefresh;

  final AutoRefreshAuthConfig config;
  final String baseUrl;
  final Future<AuthTokenPair?> Function(String refreshToken) _onRefresh;
  final void Function(AuthTokenPair tokens)? onTokenRefreshed;
  final void Function()? onAuthFailed;
  final void Function(String message)? onLog;

  String _refreshToken;
  String? _accessToken;
  DateTime? _tokenObtainedAt;
  late var _expiresInSeconds = config.defaultExpiresInSeconds;
  var _isRefreshing = false;

  bool get _isTokenExpiringSoon {
    if (_accessToken == null || _tokenObtainedAt == null) return true;

    final elapsed = DateTime.now().difference(_tokenObtainedAt!).inSeconds;
    return elapsed >= (_expiresInSeconds - config.refreshBufferSeconds);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isTokenExpiringSoon && !_isRefreshing) {
      await _refreshAndStore();
    }

    if (_accessToken != null) {
      final existing = options.headers['cookie'] as String? ?? '';
      options.headers['cookie'] = CookieUtils.mergeCookieHeaders(
        existing,
        '${config.cookieName}=$_accessToken',
      );
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return super.onError(err, handler);
    }

    final success = await _refreshAndStore();
    if (!success) {
      return super.onError(err, handler);
    }

    try {
      final opts = err.requestOptions;
      opts.headers['cookie'] = CookieUtils.mergeCookieHeaders(
        opts.headers['cookie'] as String? ?? '',
        '${config.cookieName}=$_accessToken',
      );
      final response = await Dio(BaseOptions(baseUrl: baseUrl)).fetch(opts);
      return handler.resolve(response);
    } catch (_) {
      return super.onError(err, handler);
    }
  }

  Future<bool> _refreshAndStore() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    onLog?.call('Attempting token refresh');
    try {
      final tokens = await _onRefresh(_refreshToken);
      if (tokens == null) {
        onLog?.call('Token refresh returned null');
        _accessToken = null;
        _tokenObtainedAt = null;
        onAuthFailed?.call();
        return false;
      }

      onLog?.call(
        'Token refresh succeeded, expires in ${tokens.expiresInSeconds}s',
      );
      _accessToken = tokens.accessToken;
      _refreshToken = tokens.refreshToken;
      _tokenObtainedAt = DateTime.now();
      if (tokens.expiresInSeconds != null) {
        _expiresInSeconds = tokens.expiresInSeconds!;
      }
      onTokenRefreshed?.call(tokens);
      return true;
    } catch (e) {
      onLog?.call('Token refresh failed: $e');
      onAuthFailed?.call();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void setAccessToken(String token) {
    _accessToken = token;
    _tokenObtainedAt = DateTime.now();
  }
}
