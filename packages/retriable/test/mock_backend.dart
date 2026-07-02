import 'dart:async';
import 'dart:io';

typedef RequestHandler = FutureOr<void> Function(HttpRequest request);

class MockBackend {
  MockBackend._(this._server);

  final HttpServer _server;
  StreamSubscription<HttpRequest>? _subscription;
  final _handlers = <String, RequestHandler>{};
  final _requestCounts = <String, int>{};

  static Future<MockBackend> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final backend = MockBackend._(server);
    backend._subscription = server.listen(backend._handle);

    return backend;
  }

  Uri uri(String path) => Uri(
    scheme: 'http',
    host: _server.address.host,
    port: _server.port,
    path: path,
  );

  int requestCount(String path) => _requestCounts[path] ?? 0;

  void script(
    String path,
    List<int> statusCodes, {
    String successBody = 'ok',
  }) {
    if (statusCodes.isEmpty) {
      throw ArgumentError.value(
        statusCodes,
        'statusCodes',
        'must not be empty',
      );
    }

    _handlers[path] = (request) async {
      final count = (_requestCounts[path] ?? 0) + 1;
      _requestCounts[path] = count;

      final index = count - 1 < statusCodes.length
          ? count - 1
          : statusCodes.length - 1;
      final statusCode = statusCodes[index];

      request.response
        ..statusCode = statusCode
        ..headers.contentType = ContentType.text
        ..write(statusCode == 200 ? successBody : 'status $statusCode');
      await request.response.close();
    };
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _server.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    final handler = _handlers[request.uri.path];
    if (handler == null) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('not found');
      await request.response.close();
      return;
    }

    await handler(request);
  }
}
