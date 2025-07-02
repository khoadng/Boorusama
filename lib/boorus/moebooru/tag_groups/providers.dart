// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../posts/types.dart';
import '../tags/providers.dart';

final moebooruTagGroupRepoProvider =
    Provider.family<TagGroupRepository<MoebooruPost>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        final allTagMap =
            await ref.watch(moebooruAllTagsProvider(config).future);

        return createMoebooruTagGroupItems(post.tags, allTagMap);
      },
    );
  },
);

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
