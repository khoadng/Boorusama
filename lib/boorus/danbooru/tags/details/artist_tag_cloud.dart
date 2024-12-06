// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/related_tags/related_tags.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/related_tags/related_tags.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../danbooru_tag_context_menu.dart';

const _kTagCloudTotal = 30;

final danbooruRelatedTagCloudProvider =
    FutureProvider.autoDispose.family<List<DanbooruRelatedTagItem>, String>(
  (ref, tag) async {
    final repo = ref.watch(danbooruRelatedTagRepProvider(ref.watchConfigAuth));
    final relatedTag = await repo.getRelatedTag(tag);

    final sorted = relatedTag.tags.sorted(
      (a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity),
    );

    return sorted.take(_kTagCloudTotal).toList();
  },
);

typedef TagColorParams = ({
  String categories,
});

final _tagCategoryColorsProvider =
    FutureProvider.autoDispose.family<Map<String, Color?>, TagColorParams>(
  (ref, params) async {
    final colors = <String, Color?>{};

    final categories = params.categories.split('|');

    for (final category in categories) {
      colors[category] = ref.watch(tagColorProvider(category));
    }

    return colors;
  },
  dependencies: [
    tagColorProvider,
  ],
);

class ArtistTagCloud extends ConsumerWidget {
  const ArtistTagCloud({
    super.key,
    required this.tagName,
    this.scaleFactor,
  });

  final String tagName;
  final double? scaleFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(danbooruRelatedTagCloudProvider(tagName)).when(
          data: (tags) {
            if (tags.isEmpty) return const SizedBox.shrink();

            final params = (
              categories: tags
                  .map((e) => e.category.name)
                  .toSet()
                  .sorted((a, b) => a.compareTo(b))
                  .join('|'),
            );

            return ref.watch(_tagCategoryColorsProvider(params)).when(
                  data: (tagColors) => TagCloud(
                    scaleFactor: scaleFactor,
                    itemCount: tags.length,
                    itemBuilder: (context, i) => DanbooruTagContextMenu(
                      tag: tags[i].tag,
                      child: RelatedTagCloudChip(
                        index: i,
                        tag: tags[i].tag,
                        color: tagColors[tags[i].category.name],
                        onPressed: () => goToSearchPage(
                          context,
                          tag: tags[i].tag,
                        ),
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  loading: () => _buildDummy(context),
                );
          },
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => _buildDummy(context),
        );
  }

  Widget _buildDummy(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
