// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/widgets/tag_detail_region.dart';
import 'package:boorusama/boorus/core/widgets/tag_details_sliver_app_bar.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';

class TagDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const TagDetailsPageScaffold({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    this.extraBuilder,
    required this.gridBuilder,
    this.onCategoryToggle,
  });

  final String tagName;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final Widget Function(
    BuildContext context,
    List<Widget> slivers,
  ) gridBuilder;
  final List<Widget> Function(BuildContext context)? extraBuilder;
  final void Function(TagFilterCategory category)? onCategoryToggle;

  @override
  ConsumerState<TagDetailsPageScaffold<T>> createState() =>
      _DanbooruTagDetailsPageState<T>();
}

class _DanbooruTagDetailsPageState<T extends Post>
    extends ConsumerState<TagDetailsPageScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: TagDetailsRegion(
        detailsBuilder: (context) => Column(
          children: [
            TagTitleName(tagName: widget.tagName),
            const SizedBox(height: 12),
            widget.otherNamesBuilder(context),
            ...widget.extraBuilder?.call(context) ?? [],
            const SizedBox(height: 36),
          ],
        ),
        builder: (_) {
          final slivers = [
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
            ],
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 10),
              sliver: SliverToBoxAdapter(
                child: CategoryToggleSwitch(
                  onToggle: (category) {
                    widget.onCategoryToggle?.call(category);
                  },
                ),
              ),
            ),
          ];

          return widget.gridBuilder.call(
            context,
            slivers,
          );
        },
      ),
    );
  }
}
