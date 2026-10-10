import 'dart:convert';
import 'dart:typed_data';

import 'package:booru_clients/sankaku.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('expired sessions', () {
    final rejections = [
      (
        name: 'an invalid token code',
        response: _json({'code': 'invalid_token'}),
      ),
      (name: 'an unauthorized status', response: _json({}, status: 401)),
    ];

    for (final r in rejections) {
      test('log in again and retry once after ${r.name}', () async {
        final server = _FakeServer(
          posts: (auth) => auth == 'Bearer fresh' ? _json([_post]) : r.response,
        );
        final client = server.client(
          store: InMemoryAuthStore()..saveToken(_token('stale')),
        );

        final posts = await client.getPosts();

        expect(posts.map((p) => p.id?.valueString), ['1']);
        expect(server.logins, 1);
        expect(server.postAuth, ['Bearer stale', 'Bearer fresh']);
      });
    }

    test('fail when the fresh session is rejected too', () async {
      final server = _FakeServer(
        posts: (_) => _json({'code': 'invalid_token'}),
      );
      final client = server.client(
        store: InMemoryAuthStore()..saveToken(_token('stale')),
      );

      await expectLater(
        client.getPosts(),
        throwsA(isA<SankakuAuthenticationException>()),
      );
      expect(server.logins, 1);
    });

    test('requests waiting on a login share it', () async {
      final server = _FakeServer(posts: (_) => _json([_post]));
      final client = server.client(store: InMemoryAuthStore());

      await Future.wait([
        client.getPosts(),
        client.getPosts(),
        client.getPosts(page: 2),
      ]);

      expect(server.logins, 1);
    });

    test('a rejected favorite reports failure and logs in next time', () async {
      final server = _FakeServer(
        posts: (_) => _json([_post]),
        favorite: (auth) => auth == 'Bearer stale'
            ? _json({'code': 'invalid_token'})
            : _json({'success': true}),
      );
      final client = server.client(
        store: InMemoryAuthStore()..saveToken(_token('stale')),
      );

      expect(await client.addToFavorites(postId: IntId(1)), isFalse);
      expect(await client.addToFavorites(postId: IntId(1)), isTrue);
      expect(server.logins, 1);
    });
  });

  group('login', () {
    final cases = [
      (name: 'a failed login', body: {'success': false, 'error': 'bad'}),
      (
        name: 'a login without a token',
        body: {'success': true, 'token_type': 'Bearer'},
      ),
    ];

    for (final c in cases) {
      test('rejects ${c.name} without storing a token', () async {
        final store = InMemoryAuthStore();
        final server = _FakeServer(
          posts: (_) => _json([_post]),
          login: () => _json(c.body),
        );

        await expectLater(
          server.client(store: store).getPosts(),
          throwsA(isA<SankakuAuthenticationException>()),
        );
        expect(await store.getToken(), isNull);
      });
    }
  });
}

final _post = {'id': 1};

Token _token(String access) => Token(
  success: true,
  tokenType: 'Bearer',
  accessToken: access,
  refreshToken: null,
  currentUser: null,
);

ResponseBody _json(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

class _FakeServer implements HttpClientAdapter {
  _FakeServer({
    required this.posts,
    ResponseBody Function()? login,
    ResponseBody Function(String? auth)? favorite,
  }) : login =
           login ??
           (() => _json({
             'success': true,
             'token_type': 'Bearer',
             'access_token': 'fresh',
           })),
       favorite = favorite ?? ((_) => _json({'success': true}));

  final ResponseBody Function(String? auth) posts;
  final ResponseBody Function() login;
  final ResponseBody Function(String? auth) favorite;

  var logins = 0;
  final postAuth = <String?>[];

  SankakuClient client({required AuthStore store}) => SankakuClient(
    baseUrl: 'https://example.com',
    dio: Dio()..httpClientAdapter = this,
    authStore: store,
    username: 'user',
    password: 'pass',
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final auth = options.headers['Authorization'] as String?;
    final path = options.uri.path;

    if (path == '/auth/token') {
      logins++;
      return login();
    }
    if (path.endsWith('/favorite')) return favorite(auth);

    postAuth.add(auth);
    return posts(auth);
  }

  @override
  void close({bool force = false}) {}
}
