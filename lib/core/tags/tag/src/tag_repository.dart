// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../posts/post/post.dart';
import 'tag.dart';
import 'tag_group_item.dart';

abstract class TagRepository {
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  });
}

class TagGroupOptions {
  const TagGroupOptions({
    this.fetchTagCount = false,
  });

  final bool fetchTagCount;
}

abstract class TagGroupRepository<T extends Post> {
  Future<List<TagGroupItem>> getTagGroups(
    T post, {
    TagGroupOptions options = const TagGroupOptions(),
  });
}

abstract class TagExtractor<T extends Post> {
  FutureOr<List<Tag>> extractTags(T post);
}
