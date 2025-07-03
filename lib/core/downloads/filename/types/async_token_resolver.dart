// Project imports:
import '../../../posts/post/post.dart';
import '../../../tags/categories/tag_category.dart';
import 'token_options.dart';

abstract class AsyncTokenResolver<T extends Post> {
  String get groupKey;
  Set<String> get tokenKeys;
  Future<Map<String, String?>> resolve(
    T post,
    DownloadFilenameTokenOptions options,
  );
}

typedef TagDto = ({
  String? name,
  String? type,
});

class ClassicTagsTokenResolver<T extends Post>
    implements AsyncTokenResolver<T> {
  ClassicTagsTokenResolver({
    required this.tagFetcher,
  });

  final Future<List<TagDto>> Function(T post) tagFetcher;

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
    DownloadFilenameTokenOptions options,
  ) async {
    final tags = await tagFetcher(post);

    final groupedTags = <String, String>{};

    for (final tag in tags) {
      final category = TagCategory.fromLegacyIdString(tag.type).name;
      final name = tag.name?.replaceAll('_', ' ');

      if (name == null || name.isEmpty) continue;

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
      if (artists != null) 'artist': artists,
      if (characters != null) 'character': characters,
      if (copyrights != null) 'copyright': copyrights,
      if (general != null) 'general': general,
      if (meta != null) 'meta': meta,
    };
  }
}
