// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/related_tags/related_tags.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../../related_tags/related_tags.dart';
import '../danbooru_tag_context_menu.dart';

const _kTagCloudTotal = 30;

class DanbooruTagDetailsPage extends ConsumerStatefulWidget {
  const DanbooruTagDetailsPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
    this.extraBuilder,
  });

  final String tagName;
  final String backgroundImageUrl;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final List<Widget> Function(BuildContext context)? extraBuilder;

  @override
  ConsumerState<DanbooruTagDetailsPage> createState() =>
      _DanbooruTagDetailsPageState();
}

class _DanbooruTagDetailsPageState
    extends ConsumerState<DanbooruTagDetailsPage> {
  final _dummyTags = generateDummyTags(_kTagCloudTotal);
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final postRepo = ref.watch(danbooruArtistCharacterPostRepoProvider(config));

    return TagDetailsRegion(
      detailsBuilder: (context) => Column(
        children: [
          TagTitleName(tagName: widget.tagName),
          const SizedBox(height: 12),
          widget.otherNamesBuilder(context),
          ...widget.extraBuilder?.call(context) ?? [],
          isDesktopPlatform()
              ? const SizedBox(height: 36)
              : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTagCloud(),
          ),
        ],
      ),
      builder: (_) => PostScope(
        fetcher: (page) => postRepo.getPosts(
          queryFromTagFilterCategory(
            category: selectedCategory.value,
            tag: widget.tagName,
            builder: tagFilterCategoryToString,
          ),
          page,
        ),
        builder: (context, controller, errors) {
          final widgets = [
            () => TagTitleName(tagName: widget.tagName),
            () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: widget.otherNamesBuilder(context),
                    ),
                  ],
                ),
            if (widget.extraBuilder != null)
              for (final extra in widget.extraBuilder!.call(context))
                () => extra,
            () => const SizedBox(height: 20),
            () => _buildTagCloud(),
            () => const SizedBox(height: 20),
            () => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CategoryToggleSwitch(
                    onToggle: (category) {
                      selectedCategory.value = category;
                      controller.refresh();
                    },
                  ),
                ),
          ];

          final headers = [
            if (kPreferredLayout.isMobile &&
                context.orientation.isPortrait) ...[
              TagDetailsSlilverAppBar(
                tagName: widget.tagName,
              ),
              SliverList.builder(
                itemCount: widgets.length,
                itemBuilder: (context, index) => widgets[index].call(),
              ),
            ] else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 10),
                sliver: SliverToBoxAdapter(
                  child: CategoryToggleSwitch(
                    onToggle: (category) {
                      selectedCategory.value = category;
                      controller.refresh();
                    },
                  ),
                ),
              ),
          ];

          return DanbooruInfinitePostList(
            errors: errors,
            controller: controller,
            sliverHeaders: headers,
          );
        },
      ),
    );
  }

  Widget _buildTagCloud() {
    return ArtistTagCloud(
      tagName: widget.tagName,
      dummyTags: _dummyTags,
    );
  }
}

final danbooruRelatedTagCloudProvider =
    FutureProvider.autoDispose.family<List<DanbooruRelatedTagItem>, String>(
  (ref, tag) async {
    final repo = ref.watch(danbooruRelatedTagRepProvider(ref.watchConfig));
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
    required this.dummyTags,
  });

  final String tagName;
  final List<DanbooruRelatedTagItem> dummyTags;

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
