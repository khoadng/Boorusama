// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/tags/tags.dart';
import '../common.dart';

class MockApi extends Mock implements DanbooruApi {}

void main() {
  test('get blacklisted tags should return correct tags', () async {
    final tags = ['foo', 'bar'];
    final repo = BlacklistedTagsRepositoryImpl(
      mockUserRepo(tags),
      mockUserBooruRepo(),
      MockApi(),
    );

    final expected = await repo.getBlacklistedTags(1);

    expect(listEquals(expected, tags), isTrue);
  });

  test('set tags should update blacklisted tag correctly', () async {
    final tags = ['foo', 'bar'];
    final newTags = [...tags, 'foobar'];
    final mockApi = MockApi();

    when(() => mockApi.setBlacklistedTags(any(), any(), any(), any()))
        .thenAnswer(
      (_) async => HttpResponse(
        null,
        Response(requestOptions: RequestOptions(path: '')),
      ),
    );

    final repo = BlacklistedTagsRepositoryImpl(
      mockUserRepo(tags),
      mockUserBooruRepo(),
      mockApi,
    );

    final success = await repo.setBlacklistedTags(0, newTags);

    expect(success, isTrue);
  });
}
