// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import '../../foundation/display.dart';
import 'page_preview.dart';
import 'theme_previewer_notifier.dart';

class ThemePreviewPageView extends StatefulWidget {
  const ThemePreviewPageView({super.key});

  @override
  State<StatefulWidget> createState() => _ThemePreviewPageViewState();
}

class _ThemePreviewPageViewState extends State<ThemePreviewPageView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = !context.isLargeScreen
        ? const EdgeInsets.symmetric(
            horizontal: 42,
          )
        : const EdgeInsets.symmetric(
            horizontal: 60,
          );

    final pages = [
      Transform.scale(
        alignment: Alignment.topCenter,
        scale: 0.8,
        child: Padding(
          padding: padding,
          child: const PreviewHome(),
        ),
      ),
      Transform.scale(
        alignment: Alignment.topCenter,
        scale: 0.8,
        child: Padding(
          padding: padding,
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            removeRight: true,
            child: const PreviewDetails(),
          ),
        ),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer(
          builder: (_, ref, __) {
            final currentColors = ref.watch(themePreviewerColorsProvider);
            final name = currentColors.nickname ?? currentColors.name;

            return Builder(
              builder: (context) {
                final colorScheme = ref.watch(themePreviewerSchemeProvider);

                return Text(
                  name.sentenceCase,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: colorScheme.onSurface,
                  ),
                );
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Consumer(
            builder: (_, ref, __) {
              final colorScheme = ref.watch(themePreviewerSchemeProvider);

              return SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: WormEffect(
                  activeDotColor: colorScheme.primary,
                  dotColor: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  dotHeight: 8,
                  dotWidth: 16,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: pages,
          ),
        ),
      ],
    );
  }
}
