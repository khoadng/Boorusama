// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';

class TagDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const TagDetailsPageScaffold({
    super.key,
    required this.tagName,
    required this.otherNames,
    this.extras,
    required this.gridBuilder,
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
            widget.otherNames,
            ...widget.extras ?? [],
            isDesktopPlatform()
                ? const SizedBox(height: 36)
                : const SizedBox.shrink(),
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
