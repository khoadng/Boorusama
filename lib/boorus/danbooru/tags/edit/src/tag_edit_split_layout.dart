// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import 'tag_edit_view_controller.dart';

class TagEditSplitLayout extends StatelessWidget {
  const TagEditSplitLayout({
    required this.imageBuilder,
    required this.contentBuilder,
    required this.viewController,
    super.key,
  });

  final Widget Function() imageBuilder;
  final Widget Function(double maxHeight) contentBuilder;
  final TagEditViewController viewController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: Screen.of(context).size == ScreenSize.small
            ? _buildSplit(context)
            : Row(
                children: [
                  Expanded(
                    child: imageBuilder(),
                  ),
                  const VerticalDivider(
                    width: 4,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    width: min(
                      MediaQuery.of(context).size.width * 0.4,
                      400,
                    ),
                    child: contentBuilder(constraints.maxHeight),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSplit(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Theme.of(context).colorScheme.primary,
      ),
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            color: Theme.of(context).colorScheme.onSurface,
            thickness: 4,
            size: 75,
            highlightedColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: MultiSplitView(
          axis: Axis.vertical,
          controller: viewController.splitController,
          builder: (context, area) => switch (area.data) {
            'image' => Column(
              children: [
                Expanded(
                  child: imageBuilder(),
                ),
                const Divider(
                  thickness: 1,
                  height: 4,
                ),
              ],
            ),
            'content' => LayoutBuilder(
              builder: (context, constraints) =>
                  contentBuilder(constraints.maxHeight),
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
