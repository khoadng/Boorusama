// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'related_tag_cloud_chip.dart';

Widget provideArtistPageDependencies(
  BuildContext context, {
  required String artist,
  required Widget page,
}) =>
    DanbooruProvider(
      builder: (_) {
        return CustomContextMenuOverlay(
          child: page,
        );
      },
    );

class DanbooruArtistPage extends ConsumerStatefulWidget {
  const DanbooruArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return provideArtistPageDependencies(
      context,
      artist: tag,
      page: DanbooruArtistPage(
        artistName: tag,
        backgroundImageUrl: '',
      ),
    );
  }

  @override
  ConsumerState<DanbooruArtistPage> createState() => _DanbooruArtistPageState();
}

const _kTagCloudTotal = 30;

class _DanbooruArtistPageState extends ConsumerState<DanbooruArtistPage> {
  final _dummyTags = generateDummyTags(_kTagCloudTotal);

  @override
  void initState() {
    super.initState();
    ref.read(danbooruRelatedTagsProvider.notifier).fetch(widget.artistName);
  }

  @override
  Widget build(BuildContext context) {
    final artist = ref.watch(danbooruArtistProvider(widget.artistName));
    final related = ref
        .watch(danbooruRelatedTagCosineSimilarityProvider(widget.artistName));
    final tags = related?.tags.take(_kTagCloudTotal).toList() ?? [];
    final theme = ref.watch(themeProvider);

    return Screen.of(context).size == ScreenSize.small
        ? TagDetailPage(
            tagName: widget.artistName,
            otherNamesBuilder: (_) => artist.when(
              data: (data) => data.otherNames.isNotEmpty
                  ? TagOtherNames(otherNames: data.otherNames)
                  : const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const SizedBox(height: 40, width: 40),
              loading: () => const TagOtherNames(otherNames: null),
            ),
            backgroundImageUrl: widget.backgroundImageUrl,
            extraBuilder: (context) => [
              if (related == null)
                SliverToBoxAdapter(
                  child: FittedBox(
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
                            theme: theme,
                            isDummy: true,
                            onPressed: () {},
                          ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: FittedBox(
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
                            theme: theme,
                            onPressed: () => goToSearchPage(
                              context,
                              tag: tags[i].tag,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
            ],
          )
        : TagDetailPageDesktop(
            tagName: widget.artistName,
            otherNamesBuilder: (_) => artist.when(
              data: (data) => TagOtherNames(otherNames: data.otherNames),
              error: (error, stackTrace) =>
                  const SizedBox(height: 40, width: 40),
              loading: () => const TagOtherNames(otherNames: null),
            ),
          );
  }
}

List<RelatedTagItem> generateDummyTags(int count) {
  return List.generate(
    count,
    (index) => RelatedTagItem(
      tag: 'tag_$index',
      cosineSimilarity: 1,
      jaccardSimilarity: 1,
      overlapCoefficient: 1,
      postCount: 1,
      category: switch (index % 10) {
        0 => TagCategory.artist,
        1 => TagCategory.charater,
        2 => TagCategory.copyright,
        3 => TagCategory.meta,
        _ => TagCategory.general,
      },
    ),
  );
}
