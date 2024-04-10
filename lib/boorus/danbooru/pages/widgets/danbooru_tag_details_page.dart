// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'related_tag_cloud_chip.dart';

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
          const SizedBox(height: 36),
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
        builder: (context, controller, errors) => DanbooruInfinitePostList(
          errors: errors,
          controller: controller,
          sliverHeaderBuilder: (context) {
            final widgets = [
              () => TagTitleName(tagName: widget.tagName),
              () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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

            return [
              if (isMobilePlatform() && context.orientation.isPortrait) ...[
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
          },
        ),
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
    FutureProvider.autoDispose.family<List<RelatedTagItem>, String>(
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
  Color primaryColor,
  AppThemeMode themeMode,
  String categories,
});

final _tagCategoryColorsProvider =
    FutureProvider.autoDispose.family<Map<String, Color?>, TagColorParams>(
  (ref, params) async {
    final colors = <String, Color?>{};

    final config = ref.watchConfig;
    final booruBuilders = ref.watch(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    final booruBuilder =
        booruBuilderFunc != null ? booruBuilderFunc(config) : null;

    final tagColorBuilder = booruBuilder?.tagColorBuilder;

    final categories = params.categories.split('|');

    for (var category in categories) {
      colors[category] = getTagColorCore(
        category,
        primaryColor: params.primaryColor,
        themeMode: params.themeMode,
        color: tagColorBuilder?.call(
          params.themeMode,
          category,
        ),
      );
    }

    return colors;
  },
);

class ArtistTagCloud extends ConsumerWidget {
  const ArtistTagCloud({
    super.key,
    required this.tagName,
    required this.dummyTags,
  });

  final String tagName;
  final List<RelatedTagItem> dummyTags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(danbooruRelatedTagCloudProvider(tagName)).when(
          data: (tags) {
            if (tags.isEmpty) return const SizedBox.shrink();

            final params = (
              primaryColor: context.colorScheme.primary,
              themeMode: context.themeMode,
              categories: tags
                  .map((e) => e.category.name)
                  .toSet()
                  .sorted((a, b) => a.compareTo(b))
                  .join('|'),
            );

            return ref.watch(_tagCategoryColorsProvider(params)).when(
                  data: (tagColors) => TagCloud(
                    itemCount: tags.length,
                    itemBuilder: (context, i) => RelatedTagCloudChip(
                      index: i,
                      tag: tags[i],
                      color: tagColors[tags[i].category.name],
                      onPressed: () => goToSearchPage(
                        context,
                        tag: tags[i].tag,
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
