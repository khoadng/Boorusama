// Package imports:
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';

final stubTagProvider = Provider<ITagRepository>((ref) {
  return FakeTagRepository();
});

class FakeTagRepository implements ITagRepository {
  @override
  Future<List<Tag>> getTagsByNameComma(String stringComma, int page,
      {CancelToken? cancelToken}) {
    return Future.value([]);
  }

  @override
  Future<List<Tag>> getTagsByNamePattern(String stringPattern, int page) {
    return Future.value([]);
  }
}
