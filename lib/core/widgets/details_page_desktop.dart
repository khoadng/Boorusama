// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/circular_icon_button.dart';

class DetailsPageDesktop extends ConsumerStatefulWidget {
  const DetailsPageDesktop({
    super.key,
    required this.mediaBuilder,
    required this.infoBuilder,
    this.initialPage = 0,
    required this.totalPages,
    required this.onPageChanged,
    required this.onExit,
    this.topRightBuilder,
  });

  final int initialPage;
  final int totalPages;
  final Widget Function(BuildContext context) mediaBuilder;
  final Widget Function(BuildContext context) infoBuilder;
  final Widget Function(BuildContext context)? topRightBuilder;
  final void Function(int page) onPageChanged;
  final void Function(int page) onExit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailsPageDesktopState();
}

class _DetailsPageDesktopState extends ConsumerState<DetailsPageDesktop> {
  late var currentPage = widget.initialPage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageChanged.call(currentPage);
    });
  }

  void _onExit() {
    widget.onExit.call(currentPage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = Screen.of(context).size == ScreenSize.small;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _nextPost(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _previousPost(),
        const SingleActivator(LogicalKeyboardKey.escape): () => _onExit(),
      },
      child: PopScope(
        onPopInvoked: (didPop) {
          if (didPop) return;
          _onExit();
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      widget.mediaBuilder(context),
                      if (currentPage < widget.totalPages - 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: MaterialButton(
                            color: Colors.black.withOpacity(0.5),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            onPressed: () => _nextPost(),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      if (currentPage > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MaterialButton(
                            color: Colors.black.withOpacity(0.5),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            onPressed: () => _previousPost(),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: MaterialButton(
                              color: Colors.black.withOpacity(0.5),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              onPressed: () => _onExit(),
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ),
                      ),
                      if (widget.topRightBuilder != null)
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSmall)
                                    CircularIconButton(
                                      onPressed: () =>
                                          showMaterialModalBottomSheet(
                                        context: context,
                                        backgroundColor: context
                                            .theme.scaffoldBackgroundColor,
                                        builder: (context) =>
                                            widget.infoBuilder(context),
                                      ),
                                      icon: const Icon(
                                        Icons.info,
                                        color: Colors.white,
                                      ),
                                    ),
                                  widget.topRightBuilder!.call(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isSmall)
                  SizedBox(
                    width: 350,
                    child: widget.infoBuilder(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextPost() {
    if (currentPage < widget.totalPages - 1) {
      setState(() {
        currentPage++;
        widget.onPageChanged.call(currentPage);
      });
    }
  }

  void _previousPost() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        widget.onPageChanged.call(currentPage);
      });
    }
  }
}
