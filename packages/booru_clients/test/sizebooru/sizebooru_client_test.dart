import 'dart:io';

import 'package:booru_clients/src/sizebooru/sizebooru_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';

const _listingHtml = '''
<html>
  <body>
    <a href="/Details/101?source=search&q=giantess">
      <div class="thumbnail-container">
        <img src="/Thumb?id=101" alt="giantess shrunken_man" />
      </div>
    </a>
    <a href="/Details/102">
      <div class="thumbnail-container">
        <img src="/Thumb?id=102" alt="growth" />
      </div>
    </a>
    <a href="/Details/101?source=related">
      <div class="thumbnail-container">
        <img src="/Thumb?id=101" alt="giantess" />
      </div>
    </a>
    <a href="/Details/103">no image here</a>
  </body>
</html>
''';

const _detailsHtml = '''
<html>
  <body>
    <center><img src="/Picture/101" alt="giantess.jpg" /></center>
    <a href="/Search/giantess">giantess</a>
    <a href="/Search/shrunken_man?pageNo=1">shrunken_man</a>
    <a href="/Search/giantess">giantess</a>
    <div class="card">
      Details
      <span>Artist: someartist</span>
      <span>Posted By: <a href="/User/1">uploader1</a></span>
      <span>Source Link: <a href="https://example.com/art">example</a></span>
      <span>Posted Date: 04/29/2026</span>
    </div>
  </body>
</html>
''';

void main() {
  late HttpServer server;
  late String baseUrl;
  late List<Request> requests;

  setUp(() async {
    requests = [];
    server = await shelf_io.serve(
      (request) {
        requests.add(request);

        return switch (request.url.path) {
          'Home' || 'Search' => Response.ok(
            _listingHtml,
            headers: {'content-type': 'text/html'},
          ),
          'Details/101' => Response.ok(
            _detailsHtml,
            headers: {'content-type': 'text/html'},
          ),
          'Tags/Json' => Response.ok(
            '{"giantess": 500, "giant": 20, "growth": 900, "gi": 5}',
            headers: {'content-type': 'application/json'},
          ),
          _ => Response.notFound('Not found'),
        };
      },
      'localhost',
      0,
    );
    baseUrl = 'http://localhost:${server.port}';
  });

  tearDown(() async {
    await server.close(force: true);
  });

  SizebooruClient client() => SizebooruClient(baseUrl: baseUrl);

  group('post listing', () {
    test('reads the home listing when no tag is given', () async {
      await client().getPosts(page: 3, limit: 20);

      expect(requests.single.url.path, 'Home');
      expect(requests.single.url.queryParameters.containsKey('q'), isFalse);
      expect(requests.single.url.queryParameters['pageNo'], '3');
      expect(requests.single.url.queryParameters['pageSize'], '20');
    });

    test('reads the search listing when a tag is given', () async {
      await client().getPosts(tags: ['giantess', ' '], page: 2);

      expect(requests.single.url.path, 'Search');
      expect(requests.single.url.queryParameters['q'], 'giantess');
      expect(requests.single.url.queryParameters['pageNo'], '2');
    });

    final pageSizeCases = [
      (limit: null, expected: '$kSizebooruDefaultPageSize'),
      (limit: 0, expected: '1'),
      (limit: 40, expected: '40'),
      (limit: 5000, expected: '$kSizebooruMaxPageSize'),
    ];

    for (final c in pageSizeCases) {
      test(
        'requests a page size of ${c.expected} for a limit of ${c.limit}',
        () async {
          await client().getPosts(limit: c.limit);

          expect(requests.single.url.queryParameters['pageSize'], c.expected);
        },
      );
    }

    test(
      'keeps the first occurrence of a post listed more than once',
      () async {
        final posts = await client().getPosts();

        expect(posts.map((e) => e.id), [101, 102]);
        expect(posts.first.tags, ['giantess', 'shrunken_man']);
      },
    );

    test('resolves listing image links against the site url', () async {
      final posts = await client().getPosts();

      expect(posts.first.thumbnailUrl, '$baseUrl/Thumb?id=101');
      expect(posts.first.fileUrl, '$baseUrl/Picture/101');
    });
  });

  group('post details', () {
    test('collects every distinct tag linked on the page', () async {
      final post = await client().getPost(101);

      expect(post?.tags, ['giantess', 'shrunken_man']);
    });

    test('reads the labelled fields of the details card', () async {
      final post = await client().getPost(101);

      expect(post?.filename, 'giantess.jpg');
      expect(post?.artist, 'someartist');
      expect(post?.uploader, 'uploader1');
      expect(post?.source, 'https://example.com/art');
      expect(post?.createdAt, DateTime(2026, 4, 29));
    });
  });

  group('autocomplete', () {
    test('returns prefix matches ordered by post count', () async {
      final results = await client().getAutocomplete(query: 'gi');

      expect(results.map((e) => e.value), ['giantess', 'giant', 'gi']);
    });

    test('caps the number of results at the given limit', () async {
      final results = await client().getAutocomplete(query: 'gi', limit: 2);

      expect(results.map((e) => e.value), ['giantess', 'giant']);
    });

    test('fetches the tag dictionary only once', () async {
      final c = client();
      await c.getAutocomplete(query: 'gi');
      await c.getAutocomplete(query: 'gr');

      expect(requests.where((e) => e.url.path == 'Tags/Json'), hasLength(1));
    });

    test('returns nothing for a blank query', () async {
      final results = await client().getAutocomplete(query: '  ');

      expect(results, isEmpty);
      expect(requests, isEmpty);
    });
  });
}
