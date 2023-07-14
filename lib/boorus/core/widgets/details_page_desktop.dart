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
  });

  final int initialPage;
  final int totalPages;
  final Widget Function(BuildContext context) mediaBuilder;
  final Widget Function(BuildContext context) infoBuilder;
  final void Function(int page) onPageChanged;

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

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _nextPost(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _previousPost(),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close),
                      ),
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
