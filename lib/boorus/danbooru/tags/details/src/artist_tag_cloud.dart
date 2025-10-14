// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/tags/related/widgets.dart';
import '../../../../../core/tags/tag/providers.dart';
import '../../related/providers.dart';
import '../../related/types.dart';
import '../../tag/widgets.dart';
import 'tag_cloud.dart';

const _kTagCloudTotal = 30;

final danbooruRelatedTagCloudProvider = FutureProvider.autoDispose
    .family<List<DanbooruRelatedTagItem>, String>(
      (ref, tag) async {
        final repo = ref.watch(
          danbooruRelatedTagRepProvider(ref.watchConfigAuth),
        );
        final relatedTag = await repo.getRelatedTag(tag);

        final sorted = relatedTag.tags.sorted(
          (a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity),
        );

        return sorted.take(_kTagCloudTotal).toList();
      },
    );

typedef TagColorParams = ({String categories, BooruConfigAuth auth});

final _tagCategoryColorsProvider = FutureProvider.autoDispose
    .family<Map<String, Color?>, TagColorParams>(
      (ref, params) {
        final colors = <String, Color?>{};

        final categories = params.categories.split('|');

        for (final category in categories) {
          colors[category] = ref.watch(
            tagColorProvider((params.auth, category)),
          );
        }

        return colors;
      },
      dependencies: [
        tagColorProvider,
      ],
    );

class ArtistTagCloud extends ConsumerWidget {
  const ArtistTagCloud({
    required this.tagName,
    super.key,
    this.scaleFactor,
  });

  final String tagName;
  final double? scaleFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(danbooruRelatedTagCloudProvider(tagName))
        .when(
          data: (tags) {
            if (tags.isEmpty) return const SizedBox.shrink();

            final params = (
              categories: tags
                  .map((e) => e.category.name)
                  .toSet()
                  .sorted((a, b) => a.compareTo(b))
                  .join('|'),
              auth: ref.watchConfigAuth,
            );

            return ref
                .watch(_tagCategoryColorsProvider(params))
                .when(
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
                          ref,
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
