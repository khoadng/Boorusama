// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import 'post_details_page_view.dart';
import 'post_details_page_view_controller.dart';
import 'sheet_dragline.dart';

class DragSheet extends StatefulWidget {
  const DragSheet({
    required this.sheetBuilder,
    required this.pageViewController,
    super.key,
  });

  final Widget Function(BuildContext, ScrollController? scrollController)
      sheetBuilder;
  final PostDetailsPageViewController pageViewController;

  @override
  State<DragSheet> createState() => _DragSheetState();
}

class _DragSheetState extends State<DragSheet> {
  final _contentScrollController = ScrollController();

  @override
  void dispose() {
    _contentScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxSize = widget.pageViewController.maxSize;
    return ValueListenableBuilder(
      valueListenable: widget.pageViewController.sheetState,
      builder: (_, state, __) {
        return DraggableScrollableSheet(
          controller: widget.pageViewController.sheetController,
          // force maxSize when expanded
          initialChildSize: state.isExpanded ? maxSize : 0.0,
          minChildSize: 0,
          maxChildSize: 0.9,
          snapSizes: [
            0,
            maxSize,
            0.9,
          ],
          shouldCloseOnMinExtent: false,
          snap: true,
          snapAnimationDuration: const Duration(milliseconds: 200),
          builder: (context, scrollController) => Scaffold(
            floatingActionButton: _buildScrollToTop(),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      _buildDivider(),
                      Expanded(
                        child: _buildSheetContent(),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _buildDrag(scrollController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollToTop() {
    return ValueListenableBuilder(
      valueListenable: widget.pageViewController.sheetState,
      builder: (_, state, __) {
        return state.isExpanded
            ? ScrollToTop(
                scrollController: _contentScrollController,
                child: BooruScrollToTopButton(
                  onPressed: () {
                    widget.pageViewController.resetSheet();
                  },
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildDivider() {
    return ValueListenableBuilder(
      valueListenable: widget.pageViewController.isItemPushed,
      builder: (_, pushed, __) => pushed
          ? const Divider(
              height: 0,
              thickness: 0.75,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDrag(
    ScrollController scrollController,
  ) {
    return ColoredBox(
      color: Colors.transparent,
      child: SingleChildScrollView(
        controller: scrollController,
        child: const SheetDragline(),
      ),
    );
  }

  Widget _buildSheetContent() {
    return Column(
      children: [
        Expanded(
          child: widget.sheetBuilder(
            context,
            _contentScrollController,
          ),
        ),
      ],
    );
  }
}
