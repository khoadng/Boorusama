// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/widgets/tag_detail_region.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
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
  void initState() {
    super.initState();
    ref.read(danbooruRelatedTagsProvider.notifier).fetch(widget.tagName);
  }

  @override
  Widget build(BuildContext context) {
    final related =
        ref.watch(danbooruRelatedTagCosineSimilarityProvider(widget.tagName));
    final tags = related?.tags.take(_kTagCloudTotal).toList() ?? [];

    return TagDetailsRegion(
      detailsBuilder: (context) => Column(
        children: [
          TagTitleName(tagName: widget.tagName),
          const SizedBox(height: 12),
          widget.otherNamesBuilder(context),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTagCloud(related, context, tags),
          ),
        ],
      ),
      builder: (_) => DanbooruPostScope(
        fetcher: (page) =>
            ref.read(danbooruArtistCharacterPostRepoProvider).getPosts(
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

  Widget _buildTagCloud(
    RelatedTag? related,
    BuildContext context,
    List<RelatedTagItem> tags,
  ) {
    return related == null
        ? FittedBox(
            child: Scatter(
              fillGaps: true,
              delegate: FermatSpiralScatterDelegate(
                ratio: context.screenAspectRatio,
              ),
              children: [
                for (var i = 0; i < _kTagCloudTotal; i++)
                  RelatedTagCloudChip(
                    index: i,
                    tag: _dummyTags[i],
                    isDummy: true,
                    onPressed: () {},
                  ),
              ],
            ),
          )
        : FittedBox(
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
  }
}
