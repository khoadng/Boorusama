// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'related_tag_cloud_chip.dart';

const _kTagCloudTotal = 30;

class DanbooruTagDetailsPage extends ConsumerStatefulWidget {
  const DanbooruTagDetailsPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
    this.extraBuilder,
    this.includeHeaders = true,
  });

  final String tagName;
  final String backgroundImageUrl;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final List<Widget> Function(BuildContext context)? extraBuilder;
  final bool includeHeaders;

  @override
  ConsumerState<DanbooruTagDetailsPage> createState() =>
      _DanbooruTagDetailsPageState();
}

class _DanbooruTagDetailsPageState
    extends ConsumerState<DanbooruTagDetailsPage> {
  final _dummyTags = generateDummyTags(_kTagCloudTotal);

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
    final theme = ref.watch(themeProvider);

    return TagDetailPage(
      tagName: widget.tagName,
      otherNamesBuilder: widget.otherNamesBuilder,
      backgroundImageUrl: widget.backgroundImageUrl,
      extraBuilder: (context) => _buildExtra(related, context, theme, tags),
      includeHeaders: widget.includeHeaders,
    );
  }

  List<Widget> _buildExtra(
    RelatedTag? related,
    BuildContext context,
    ThemeMode theme,
    List<RelatedTagItem> tags,
  ) {
    return [
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
    ];
  }
}
