// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';

//FIXME: Split view is broken, need to fix it later, check tag_edit_page.dart for the correct implementation
class TagEditUploadScaffold extends ConsumerStatefulWidget {
  const TagEditUploadScaffold({
    super.key,
    required this.modeBuilder,
    required this.contentBuilder,
    required this.aspectRatio,
    required this.imageUrl,
    this.maxSplit = false,
    this.splitWeights = const [0.5, 0.5],
    required this.imageFooterBuilder,
  });

  final Widget Function() contentBuilder;
  final Widget Function(double maxHeight) modeBuilder;
  final double aspectRatio;
  final String imageUrl;
  final bool maxSplit;
  final List<double> splitWeights;
  final Widget Function() imageFooterBuilder;

  @override
  ConsumerState<TagEditUploadScaffold> createState() => _TagEditScaffoldState();
}

class _TagEditScaffoldState extends ConsumerState<TagEditUploadScaffold> {
  final scrollController = ScrollController();
  late final splitController = MultiSplitViewController(
    areas: [
      Area(
        data: 'image',
        min: 4,
        flex: widget.splitWeights[0],
      ),
      Area(
        data: 'content',
        min: 100,
        flex: widget.splitWeights[1],
      ),
    ],
  );

  String? selectedTag;

  var viewExpanded = false;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    splitController.dispose();
  }

  @override
  void didUpdateWidget(covariant TagEditUploadScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.maxSplit != oldWidget.maxSplit) {
      if (widget.maxSplit) {
        _setMaxSplit();
      } else {
        _setDefaultSplit();
      }
    }
  }

  void _setDefaultSplit() {
    splitController.areas = [
      Area(
        data: 'image',
        min: 4,
        flex: 0.5,
      ),
      Area(
        data: 'content',
        min: 100,
        flex: 0.5,
      ),
    ];
  }

  void _setMaxSplit() {
    splitController.areas = [
      Area(
        data: 'image',
        min: 4,
        flex: 0.9,
      ),
      Area(
        data: 'content',
        min: 100,
        flex: 0.1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Symbols.arrow_back),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Screen.of(context).size == ScreenSize.small
              ? Column(
                  children: [
                    Expanded(
                      child: _buildSplit(context),
                    ),
                    _buildMode(
                      context,
                      constraints.maxHeight,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildImage(),
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
                      child: Column(
                        children: [
                          Expanded(
                            child: widget.contentBuilder(),
                          ),
                          _buildMode(
                            context,
                            constraints.maxHeight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight > 80
          ? Column(
              children: [
                Expanded(
                  child: InteractiveBooruImage(
                    useHero: false,
                    heroTag: '',
                    aspectRatio: widget.aspectRatio,
                    imageUrl: widget.imageUrl,
                  ),
                ),
                widget.imageFooterBuilder(),
              ],
            )
          : SizedBox(
              height: constraints.maxHeight,
            ),
    );
  }

  Widget _buildSplit(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        focusColor: context.colorScheme.primary,
      ),
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            color: context.colorScheme.onSurface,
            thickness: 4,
            size: 75,
            highlightedColor: context.colorScheme.primary,
          ),
        ),
        child: MultiSplitView(
          axis: Axis.vertical,
          controller: splitController,
          builder: (context, area) => switch (area.data) {
            'image' => Column(
                children: [
                  Expanded(
                    child: _buildImage(),
                  ),
                  const Divider(
                    thickness: 1,
                    height: 4,
                  ),
                ],
              ),
            'content' => widget.contentBuilder(),
            _ => const SizedBox(),
          },
          // builder: (context, area) => [
          //   Column(
          //     children: [
          //       Expanded(
          //         child: _buildImage(),
          //       ),
          //       const Divider(
          //         thickness: 1,
          //         height: 4,
          //       ),
          //     ],
          //   ),
          //   widget.contentBuilder(),
          // ],
        ),
      ),
    );
  }

  Widget _buildMode(
    BuildContext context,
    double maxHeight,
  ) {
    final height =
        viewExpanded ? max(maxHeight - kToolbarHeight - 120.0, 280.0) : 280.0;

    return widget.modeBuilder(height);
  }
}
