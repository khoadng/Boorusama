import 'package:booru_clients/src/eshuushuu/eshuushuu_client.dart';
import 'package:booru_clients/src/eshuushuu/types/search.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('EShuushuuClient', () {
    group('getTagIds', () {
      test(
        'should parse tag IDs in correct order: tags > source > char > artist',
        () async {
          final dio = Dio();
          dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 303,
                    headers: Headers.fromMap({
                      'location': [
                        'https://e-shuushuu.net/search/results/?tags=7+720+216485+228483+61653+214282',
                      ],
                    }),
                  ),
                );
              },
            ),
          );

          final client = EShuushuuClient(dio: dio);

          final request = EshuushuuSearchRequest(
            tags: '"sleep" "ahoge" ',
            source: '"Genshin Impact" ',
            character: '"Baron Bunny" "Amber" ',
            artist: '"Takemura Kou" ',
          );

          final result = await client.getTagIds(request);

          expect(result['tags'], equals([7, 720]));
          expect(result['source'], equals([216485]));
          expect(result['char'], equals([228483, 61653]));
          expect(result['artist'], equals([214282]));
          expect(result.length, equals(4));
        },
      );
    });
  });
}
