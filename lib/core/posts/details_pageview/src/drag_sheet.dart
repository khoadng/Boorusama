// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import 'post_details_page_view.dart';
import 'post_details_page_view_controller.dart';
import 'sheet_dragline.dart';

const _kOverscrollSheetCloseThreshold = -6.0;
const _kOverscrollFullSheetCloseThreshold = -24.0;
const _kOverscrollFullSheetSnapbackThreshold = -6.0;
const _kFullSheetSize = 0.9;
const _kMinSheetSize = 0.0;
const _kSnapAnimationDuration = Duration(milliseconds: 200);

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
  var _closing = false;

  @override
  void dispose() {
    _contentScrollController.dispose();

    super.dispose();
  }

  void _closeSheet() {
    // Prevent multiple close
    if (_closing) return;

    _closing = true;
    widget.pageViewController.resetSheet().then((value) => _closing = false);
  }

  double get maxSize => widget.pageViewController.maxSize;
  bool get isFullyExpanded => sheetController.size == _kFullSheetSize;
  DraggableScrollableController get sheetController =>
      widget.pageViewController.sheetController;

  void _snapSheetToMaxSize() {
    sheetController.animateTo(
      widget.pageViewController.maxSize,
      duration: _kSnapAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // Handles overscroll behavior based on the sheet's current state:
      // - Fully Expanded: Closes the sheet if overscroll exceeds the close threshold or snaps back if within snapback threshold.
      // - Partially Expanded: Closes the sheet if overscroll exceeds the close threshold.
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          // Too fast, only close when sheet is still
          if (notification.velocity < 0) return false;

          final overscrollAmount = notification.overscroll;

          if (isFullyExpanded) {
            if (overscrollAmount < _kOverscrollFullSheetCloseThreshold) {
              _closeSheet();
            } else if (overscrollAmount <
                _kOverscrollFullSheetSnapbackThreshold) {
              _snapSheetToMaxSize();
            }
          } else {
            if (overscrollAmount < _kOverscrollSheetCloseThreshold) {
              _closeSheet();
            }
          }
        }

        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: widget.pageViewController.sheetState,
        builder: (_, state, __) {
          return DraggableScrollableSheet(
            controller: sheetController,
            // force maxSize when expanded
            initialChildSize: state.isExpanded ? maxSize : _kMinSheetSize,
            minChildSize: _kMinSheetSize,
            maxChildSize: _kFullSheetSize,
            snapSizes: [
              _kMinSheetSize,
              maxSize,
              _kFullSheetSize,
            ],
            shouldCloseOnMinExtent: false,
            snap: true,
            snapAnimationDuration: _kSnapAnimationDuration,
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
      ),
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
