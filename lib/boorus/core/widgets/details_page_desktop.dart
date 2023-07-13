// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailsPageDesktop extends ConsumerStatefulWidget {
  const DetailsPageDesktop({
    super.key,
    required this.mediaBuilder,
    required this.infoBuilder,
  });

  final Widget Function(BuildContext context, int index) mediaBuilder;
  final Widget Function(BuildContext context, int index) infoBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailsPageDesktopState();
}

class _DetailsPageDesktopState extends ConsumerState<DetailsPageDesktop> {
  final pageController = PageController();
  late var currentPage = ValueNotifier<int>(pageController.initialPage);

  @override
  void initState() {
    super.initState();
    pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    currentPage.value = pageController.page!.round();
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemBuilder: widget.mediaBuilder,
          ),
        ),
        SizedBox(
            width: 500,
            child: ValueListenableBuilder(
              valueListenable: currentPage,
              builder: (context, index, _) =>
                  widget.infoBuilder(context, index),
            ))
      ],
    );
  }
}
