// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
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
            child: ArtistTagCloud(
              tagName: widget.tagName,
              dummyTags: _dummyTags,
            ),
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
          sliverHeaderBuilder: (context) => [
            if (isMobilePlatform() && context.orientation.isPortrait) ...[
              TagDetailsSlilverAppBar(
                tagName: widget.tagName,
              ),
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TagTitleName(tagName: widget.tagName),
                    widget.otherNamesBuilder(context),
                    ...widget.extraBuilder?.call(context) ?? [],
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: ArtistTagCloud(
                  tagName: widget.tagName,
                  dummyTags: _dummyTags,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
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
          ],
        ),
      ),
    );
  }
}

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
    final async =
        ref.watch(danbooruRelatedTagCosineSimilarityProvider(tagName));

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: async.when(
        data: (related) {
          final tags = related.tags.take(_kTagCloudTotal).toList();

          return FittedBox(
            child: Scatter(
              fillGaps: true,
              delegate: FermatSpiralScatterDelegate(
                ratio: context.screenAspectRatio,
              ),
              children: [
                for (var i = 0; i < tags.length; i++)
                  RelatedTagCloudChip(
                    index: i,
                    tag: tags[i],
                    onPressed: () => goToSearchPage(
                      context,
                      tag: tags[i].tag,
                    ),
                  ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => const SizedBox.shrink(),
        loading: () => FittedBox(
          child: Scatter(
            fillGaps: true,
            delegate: FermatSpiralScatterDelegate(
              ratio: context.screenAspectRatio,
            ),
            children: [
              for (var i = 0; i < _kTagCloudTotal; i++)
                RelatedTagCloudChip(
                  index: i,
                  tag: dummyTags[i],
                  isDummy: true,
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ),
    );
  }
}
