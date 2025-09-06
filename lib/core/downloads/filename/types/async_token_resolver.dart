// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../posts/post/post.dart';
import '../../../tags/categories/tag_category.dart';
import '../../../tags/tag/tag.dart';
import 'token_options.dart';

abstract class AsyncTokenResolver<T extends Post> {
  String get groupKey;
  Set<String> get tokenKeys;
  Future<Map<String, String?>> resolve(
    T post,
    DownloadFilenameTokenOptions options, {
    CancelToken? cancelToken,
  });
}

class ClassicTagsTokenResolver<T extends Post>
    implements AsyncTokenResolver<T> {
  ClassicTagsTokenResolver({
    required this.tagExtractor,
  });

  final TagExtractor? tagExtractor;

  @override
  String get groupKey => 'tag_details';

  @override
  Set<String> get tokenKeys => {
    'artist',
    'character',
    'copyright',
    'general',
    'meta',
  };

  @override
  Future<Map<String, String?>> resolve(
    T post,
    DownloadFilenameTokenOptions options, {
    CancelToken? cancelToken,
  }) async {
    final extractor = tagExtractor;

    if (extractor == null) return {};

    final tags = await extractor.extractTags(
      post,
      options: ExtractOptions(
        cancelToken: cancelToken,
      ),
    );

    return _groupTagsByCategory(tags);
  }

  Map<String, String?> _groupTagsByCategory(List<Tag> tags) {
    final groupedTags = <String, String>{};

    for (final tag in tags) {
      final category = tag.category.name;
      final name = tag.name;

      if (name.isEmpty) continue;

      if (groupedTags.containsKey(category)) {
        groupedTags[category] = '${groupedTags[category]} $name';
      } else {
        groupedTags[category] = name;
      }
    }

    final artists = groupedTags[TagCategory.artist().name];
    final characters = groupedTags[TagCategory.character().name];
    final copyrights = groupedTags[TagCategory.copyright().name];
    final general = groupedTags[TagCategory.general().name];
    final meta = groupedTags[TagCategory.meta().name];

    return {
      'artist': ?artists,
      'character': ?characters,
      'copyright': ?copyrights,
      'general': ?general,
      'meta': ?meta,
    };
  }
}
