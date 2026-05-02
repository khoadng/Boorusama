import 'dart:io';

import 'package:booru_clients/src/shimmie2/shimmie2_client.dart';
import 'package:booru_clients/src/shimmie2/types/types.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';

void main() {
  group('Shimmie2Client extension discovery', () {
    late HttpServer server;
    late String baseUrl;
    late bool supportsInternalExtensions;
    late bool supportsLegacyExtensions;

    setUp(() async {
      supportsInternalExtensions = true;
      supportsLegacyExtensions = false;
      server = await shelf_io.serve(
        (request) {
          if (request.url.path == 'ext_doc' && supportsLegacyExtensions) {
            return Response.ok(
              """
<html>
  <body>
    <form id='extensions'>
      <table>
        <tbody>
          <tr data-ext='GraphQL'>
            <td></td>
            <td><a href='/ext_doc/graphql'>GraphQL</a></td>
            <td>Add a graphql API</td>
          </tr>
        </tbody>
      </table>
    </form>
    <footer>Shimmie version 2.11.0</footer>
  </body>
</html>
""",
              headers: {'content-type': 'text/html'},
            );
          }

          if (request.url.path == 'api/internal/extensions' &&
              supportsInternalExtensions) {
            return Response.ok(
              '["danbooru_api","graphql","user_api_keys","unknown"]',
              headers: {
                'content-type': 'application/json',
                'x-powered-by': 'Shimmie-2.12.2-20260425-0b60143',
              },
            );
          }

          return Response.notFound('Not found');
        },
        'localhost',
        0,
      );
      baseUrl = 'http://${server.address.host}:${server.port}';
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test(
      'uses legacy HTML extension data when internal API is unavailable',
      () async {
        supportsInternalExtensions = false;
        supportsLegacyExtensions = true;
        final client = Shimmie2Client(baseUrl: baseUrl);

        final result = await client.getExtensions();

        final success = result as ExtensionsSuccess;
        expect(success.source, ExtensionDiscoverySource.legacyHtml);
        expect(success.isPartial, false);
        expect(success.version.toString(), '2.11.0');
        expect(success.extensions.single.name, 'GraphQL');
        expect(success.extensions.single.description, 'Add a graphql API');
        expect(success.extensions.single.docLink, '$baseUrl/ext_doc/graphql');
      },
    );

    test('uses internal JSON extension keys when available', () async {
      final client = Shimmie2Client(baseUrl: baseUrl);

      final result = await client.getExtensions();

      final success = result as ExtensionsSuccess;
      expect(success.source, ExtensionDiscoverySource.internalJson);
      expect(success.isPartial, true);
      expect(success.version.toString(), '2.12.2');
      expect(
        success.extensions.map((e) => e.name),
        containsAll(['Danbooru Client API', 'GraphQL', 'User API Key']),
      );
      expect(success.extensions.map((e) => e.name), contains('unknown'));
    });
  });
}
