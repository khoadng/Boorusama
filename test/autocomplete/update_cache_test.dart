// Package imports:
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/dio.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/autocomplete/autocomplete_http_cache.dart';

class MockBox extends Mock implements Box<String> {}

void main() {
  test(
    'if headers has Cache-Control, put it to cache',
    () async {
      final box = MockBox();
      final cache = AutocompleteHttpCacher(box: box);
      final response = HttpResponse(
        'foo',
        Response(
          requestOptions: RequestOptions(path: ''),
          data: 'foo',
          headers: Headers.fromMap({
            'Cache-Control': ['max-age=10, public'],
          }),
        ),
      );

      when(() => box.containsKey('a')).thenReturn(true);
      when(() => box.put(any(), any())).thenAnswer((_) async => '');

      await updateCache(cache, 'a', response);

      expect(cache.exist('a'), isTrue);
    },
  );
}
