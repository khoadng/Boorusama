// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _nextPost(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _previousPost(),
        const SingleActivator(LogicalKeyboardKey.escape): () => _onExit(),
      },
      child: WillPopScope(
        onWillPop: () {
          _onExit();

          return Future.value(false);
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
                            color: Theme.of(context).cardColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            onPressed: () => _nextPost(),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      if (currentPage > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MaterialButton(
                            color: Theme.of(context).cardColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            onPressed: () => _previousPost(),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: MaterialButton(
                            color: Theme.of(context).cardColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            onPressed: () => _onExit(),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ),
                      if (widget.topRightBuilder != null)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: widget.topRightBuilder!.call(context),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 400,
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
