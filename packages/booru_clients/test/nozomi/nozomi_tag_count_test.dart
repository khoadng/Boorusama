import 'dart:typed_data';

import 'package:booru_clients/nozomi.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('tag counts', () {
    final cases = [
      (
        name: 'reads the count from the total size of a partial response',
        response: () => _bytes(
          Uint8List(4),
          206,
          headers: {
            'content-range': ['bytes 0-3/40'],
          },
        ),
        counts: {'tag': 10},
        missing: <String>{},
      ),
      (
        name: 'counts the full body when the server ignores the range',
        response: () => _bytes(Uint8List(12), 200),
        counts: {'tag': 3},
        missing: <String>{},
      ),
      (
        name: 'reports a tag without an index as missing',
        response: () => _bytes(Uint8List(0), 404),
        counts: <String, int>{},
        missing: {'tag'},
      ),
      (
        name: 'reports zero for an empty index',
        response: () => _bytes(Uint8List(0), 416),
        counts: {'tag': 0},
        missing: <String>{},
      ),
    ];

    for (final c in cases) {
      test(c.name, () async {
        final client = _client((_) => c.response());

        final lookup = await client.resolveTagCounts(['tag']);

        expect(lookup.counts, c.counts);
        expect(lookup.missing, c.missing);
      });
    }

    test('downloads only the first post id of each tag index', () async {
      final requests = <RequestOptions>[];
      final client = _client((request) {
        requests.add(request);
        return _bytes(
          Uint8List(4),
          206,
          headers: {
            'content-range': ['bytes 0-3/8'],
          },
        );
      });

      await client.resolveTagCounts(['first', 'second']);

      for (final request in requests) {
        expect(request.headers['Range'], 'bytes=0-3');
        expect(request.headers['Accept-Encoding'], 'identity');
      }
      expect(requests, hasLength(2));
    });

    test('fails when a partial response has no total size', () async {
      final client = _client((_) => _bytes(Uint8List(4), 206));

      expect(
        client.resolveTagCounts(['tag']),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

NozomiClient _client(ResponseBody Function(RequestOptions request) handler) {
  return NozomiClient(
    dio: Dio(BaseOptions(baseUrl: 'https://example.com'))
      ..httpClientAdapter = _FakeAdapter(handler),
  );
}

ResponseBody _bytes(
  Uint8List bytes,
  int statusCode, {
  Map<String, List<String>> headers = const {},
}) {
  return ResponseBody.fromBytes(bytes, statusCode, headers: headers);
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions request) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
