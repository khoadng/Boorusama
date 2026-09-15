import 'dart:typed_data';

import 'package:booru_clients/zerochan.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  test('uses a valid detail JSON full URL without requesting HTML', () async {
    final adapter = _FakeAdapter((request) {
      expect(request.uri.query, 'json');
      return _response('''
{
  "id": 3974569,
  "full": "https://static.zerochan.net/Cross-Over.full.3974569.webp",
  "large": "https://s1.zerochan.net/Cross-Over.600.3974569.jpg",
  "medium": "https://s3.zerochan.net/240/19/41/3974569.avif",
  "small": "https://s1.zerochan.net/75/19/41/3974569.jpg"
}
''');
    });
    final client = _client(adapter);

    final urls = await client.getDownloadUrls(3974569);

    expect(urls?.full, endsWith('.webp'));
    expect(adapter.requests, hasLength(1));
  });

  test('falls back once to HTML when detail JSON is malformed', () async {
    final adapter = _FakeAdapter((request) {
      if (request.uri.query == 'json') {
        return _response('{ malformed');
      }

      return _response('''
<html><body>
  <div id="large"><a class="preview" href="https://static.zerochan.net/Kanon.full.4257916.jpg">full</a></div>
</body></html>
''', contentType: 'text/html');
    });
    final client = _client(adapter);

    final urls = await client.getDownloadUrls(4257916);

    expect(urls?.full, 'https://static.zerochan.net/Kanon.full.4257916.jpg');
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests.last.uri.path, '/4257916');
  });

  test(
    'merges explicit detail variants with an HTML original fallback',
    () async {
      final adapter = _FakeAdapter((request) {
        if (request.uri.query == 'json') {
          return _response('''
{
  "id": 12,
  "large": "https://s1.zerochan.net/Kanon.600.12.jpg",
  "medium": "https://s3.zerochan.net/240/12.avif"
}
''');
        }

        return _response('''
<div id="large"><a href="//static.zerochan.net/Kanon.full.12.jpg" class="preview">full</a></div>
''', contentType: 'text/html');
      });
      final client = _client(adapter);

      final urls = await client.getDownloadUrls(12);

      expect(urls?.full, 'https://static.zerochan.net/Kanon.full.12.jpg');
      expect(urls?.large, 'https://s1.zerochan.net/Kanon.600.12.jpg');
      expect(urls?.medium, 'https://s3.zerochan.net/240/12.avif');
    },
  );

  test(
    'uses Asiachan HTML directly and honors anchor attribute order',
    () async {
      final adapter = _FakeAdapter((request) {
        expect(request.uri.query, isEmpty);
        return _response('''
<div id="large">
  <a href="https://static.asiachan.com/LE.SSERAFIM.full.498170.jpg" class="preview">full</a>
</div>
''', contentType: 'text/html');
      });
      final client = _client(adapter, baseUrl: 'https://kpop.asiachan.com');

      final urls = await client.getDownloadUrls(498170);

      expect(
        urls?.full,
        'https://static.asiachan.com/LE.SSERAFIM.full.498170.jpg',
      );
      expect(adapter.requests, hasLength(1));
    },
  );

  test('gives the post anchor priority over Open Graph metadata', () async {
    final adapter = _FakeAdapter(
      (request) => _response('''
<div id="large">
  <a class="preview" href="/images/Kanon.full.12.jpg">full</a>
</div>
<meta name="og:image" content="https://static.zerochan.net/logo.full.jpg">
''', contentType: 'text/html'),
    );
    final client = _client(adapter, baseUrl: 'https://www.zerochan.net');

    final urls = await client.getDownloadUrls(12);

    expect(urls?.full, 'https://www.zerochan.net/images/Kanon.full.12.jpg');
  });

  for (final attribute in ['property', 'name']) {
    test('accepts the $attribute Open Graph image form', () async {
      final adapter = _FakeAdapter(
        (request) => _response('''
<meta $attribute="og:image" content="https://static.zerochan.net/Kanon.full.12.jpg">
''', contentType: 'text/html'),
      );
      final client = _client(adapter, baseUrl: 'https://www.zerochan.net');

      final urls = await client.getDownloadUrls(12);

      expect(urls?.full, 'https://static.zerochan.net/Kanon.full.12.jpg');
      expect(adapter.requests, hasLength(2));
    });
  }

  test(
    'does not fabricate an original from an error page or unsupported link',
    () async {
      final adapter = _FakeAdapter((request) {
        if (request.uri.query == 'json') return _response('{}');

        return _response('''
<div id="large"><a class="preview" href="javascript:alert(1)">bad</a></div>
<meta name="og:image" content="https://static.zerochan.net/logo.full.jpg">
''', contentType: 'text/html');
      });
      final client = _client(adapter);

      expect(await client.getDownloadUrls(12), isNull);
    },
  );

  test(
    'propagates detail transport failures without an immediate fallback',
    () async {
      final adapter = _FakeAdapter((request) {
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        );
      });
      final client = _client(adapter);

      await expectLater(
        client.getDownloadUrls(12),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
    },
  );

  for (final status in [404, 410]) {
    test('skips a confirmed $status post and retries later', () async {
      var jsonAttempts = 0;
      final jsonAdapter = _FakeAdapter((request) {
        jsonAttempts++;
        if (jsonAttempts == 1) return _response('', status: status);

        return _response(
          '{"id": 12, "full": "https://static.zerochan.net/Kanon.full.12.jpg"}',
        );
      });
      final jsonClient = _client(jsonAdapter);

      expect(await jsonClient.getDownloadUrls(12), isNull);
      final jsonRetry = await jsonClient.getDownloadUrls(12);

      expect(jsonRetry?.full, 'https://static.zerochan.net/Kanon.full.12.jpg');
      expect(jsonAdapter.requests, hasLength(2));
      expect(
        jsonAdapter.requests.every((request) => request.uri.query == 'json'),
        isTrue,
      );

      var htmlAttempts = 0;
      final htmlAdapter = _FakeAdapter((request) {
        htmlAttempts++;
        if (htmlAttempts == 1) return _response('', status: status);

        return _response('''
<div id="large"><a class="preview" href="https://static.asiachan.com/Kanon.full.12.jpg">full</a></div>
''', contentType: 'text/html');
      });
      final htmlClient = _client(
        htmlAdapter,
        baseUrl: 'https://kpop.asiachan.com',
      );

      expect(await htmlClient.getDownloadUrls(12), isNull);
      final htmlRetry = await htmlClient.getDownloadUrls(12);

      expect(htmlRetry?.full, 'https://static.asiachan.com/Kanon.full.12.jpg');
      expect(htmlAdapter.requests, hasLength(2));
    });
  }
}

ZerochanClient _client(
  _FakeAdapter adapter, {
  String baseUrl = 'https://www.zerochan.net',
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = adapter;
  return ZerochanClient(dio: dio, baseUrl: baseUrl);
}

ResponseBody _response(
  String body, {
  String contentType = 'application/json',
  int status = 200,
}) => ResponseBody.fromString(
  body,
  status,
  headers: {
    Headers.contentTypeHeader: [contentType],
  },
);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions request) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
