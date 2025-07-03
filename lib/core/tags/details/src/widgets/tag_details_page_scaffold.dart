// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/display.dart';
import '../../../../../foundation/platform.dart';
import '../../../../posts/post/post.dart';
import '../../../tag/tag.dart';
import '../internal_widgets/category_toggle_switch.dart';
import '../internal_widgets/tag_detail_region.dart';
import '../internal_widgets/tag_details_sliver_app_bar.dart';
import '../internal_widgets/tag_title_name.dart';

class TagDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const TagDetailsPageScaffold({
    required this.tagName,
    required this.otherNames,
    required this.gridBuilder,
    super.key,
    this.extras,
    this.onCategoryToggle,
  });

  final String tagName;
  final Widget otherNames;
  final Widget Function(
    BuildContext context,
    List<Widget> slivers,
  ) gridBuilder;
  final List<Widget>? extras;
  final void Function(TagFilterCategory category)? onCategoryToggle;

  @override
  ConsumerState<TagDetailsPageScaffold<T>> createState() =>
      _TagDetailsPageState<T>();
}

class _TagDetailsPageState<T extends Post>
    extends ConsumerState<TagDetailsPageScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: TagDetailsRegion(
        detailsBuilder: (context) => Column(
          children: [
            TagTitleName(tagName: widget.tagName),
            const SizedBox(height: 12),
            widget.otherNames,
            ...widget.extras ?? [],
            if (isDesktopPlatform())
              const SizedBox(height: 36)
            else
              const SizedBox.shrink(),
          ],
        ),
        builder: (context) {
          final widgets = [
            () => TagTitleName(tagName: widget.tagName),
            () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: widget.otherNames,
                    ),
                  ],
                ),
            if (widget.extras != null)
              for (final extra in widget.extras!) () => extra,
            () => const SizedBox(height: 20),
            () => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CategoryToggleSwitch(
                    onToggle: (category) {
                      widget.onCategoryToggle?.call(category);
                    },
                  ),
                ),
          ];

          return widget.gridBuilder.call(
            context,
            [
              if (!context.isLargeScreen) ...[
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
                        widget.onCategoryToggle?.call(category);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
