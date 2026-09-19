// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Package imports:
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:win_http/win_http.dart';

/// Bridges Dio to Windows' native WinHTTP/Schannel transport.
///
/// Cloudflare clearance obtained in WebView2 can be rejected when replayed
/// through Dart's socket/TLS stack. WinHTTP keeps API requests in Dio while
/// using the native Windows network stack for the actual connection.
class WinHttpDioAdapter implements HttpClientAdapter {
  WinHttpDioAdapter({String? userAgent})
    : _client = WinHttpClient.fromConfiguration(
        WinHttpClientConfiguration(
          userAgent: userAgent,
          maxConnectionsPerServer: 32,
        ),
      );

  final http.Client _client;
  var _closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) {
      throw StateError('WinHttpDioAdapter is closed');
    }

    final request =
        http.AbortableRequest(
            options.method,
            options.uri,
            abortTrigger: cancelFuture,
          )
          ..followRedirects = options.followRedirects
          ..maxRedirects = options.maxRedirects
          ..persistentConnection = options.persistentConnection;

    options.headers.forEach((name, value) {
      if (value == null) return;
      request.headers[name] = _headerValue(name, value);
    });

    if (requestStream != null) {
      final body = BytesBuilder(copy: false);
      await requestStream.forEach(body.add);
      request.bodyBytes = body.takeBytes();
    }

    final response = await _client.send(request);
    final headers = <String, List<String>>{
      for (final entry in response.headers.entries) entry.key: [entry.value],
    };

    return ResponseBody(
      response.stream.map(
        (chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk),
      ),
      response.statusCode,
      statusMessage: response.reasonPhrase,
      isRedirect: response.isRedirect,
      headers: headers,
    );
  }

  String _headerValue(String name, Object value) {
    if (value is! Iterable) return value.toString();
    final separator = name.toLowerCase() == 'cookie' ? '; ' : ', ';
    return value.map((item) => item.toString()).join(separator);
  }

  @override
  void close({bool force = false}) {
    if (_closed) return;
    _closed = true;
    _client.close();
  }
}
