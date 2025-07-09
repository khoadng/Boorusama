// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/boorus/booru/booru.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';
import '../posts/types.dart';
import '../tag_summary/providers.dart';
import 'parser.dart';
import 'repository.dart';

final moebooruTagRepoProvider =
    Provider.family<MoebooruTagRepository, BooruConfigAuth>((ref, config) {
      return MoebooruTagRepository(
        repo: ref.watch(moebooruTagSummaryRepoProvider(config)),
      );
    });

final moebooruTagExtractorProvider =
    Provider.family<TagExtractor<MoebooruPost>, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          sorter: TagSorter.defaults(),
          fetcher: (post, options) async {
            final allTagMap = await ref.read(
              moebooruAllTagsProvider(config).future,
            );

            final tags = <Tag>[];

            for (final t in post.tags) {
              final tag = allTagMap[t];
              if (tag != null) {
                tags.add(tag);
              } else {
                tags.add(
                  Tag.noCount(
                    name: t,
                    category: TagCategory.unknown(),
                  ),
                );
              }
            }

            return tags;
          },
        );
      },
    );

final moebooruAllTagsProvider =
    FutureProvider.family<Map<String, Tag>, BooruConfigAuth>((
      ref,
      config,
    ) async {
      if (config.booruType != BooruType.moebooru) return {};

      final repo = ref.watch(moebooruTagSummaryRepoProvider(config));
      final data = await repo.getTagSummaries();

      final tags = data
          .map(tagSummaryToTag)
          .sorted((a, b) => a.rawName.compareTo(b.rawName));

      return {
        for (final tag in tags) tag.rawName: tag,
      };
    });

List<TagGroupItem> createMoebooruTagGroupItems(
  Set<String> tagStrings,
  Map<String, Tag> allTagsMap,
) {
  final tags = <Tag>[];

  for (final tag in tagStrings) {
    if (allTagsMap.containsKey(tag)) {
      tags.add(allTagsMap[tag]!);
    }
  }

  final tagGroups = createTagGroupItems(tags);

  return tagGroups;
}
