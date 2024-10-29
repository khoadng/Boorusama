// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'color_selector_accent.dart';
import 'color_selector_builtin.dart';
import 'color_selector_image.dart';
import 'page_preview.dart';
import 'widgets.dart';

const _kMinSheetSize = 0.3;
const _kMaxSheetSize = 0.7;

class ThemePreviewApp extends StatefulWidget {
  const ThemePreviewApp({
    super.key,
    required this.defaultScheme,
    required this.currentScheme,
    required this.onSchemeChanged,
  });

  final ColorScheme defaultScheme;
  final ColorSettings? currentScheme;
  final void Function(ColorSettings? color) onSchemeChanged;

  @override
  State<ThemePreviewApp> createState() => _ThemePreviewAppState();
}

class _ThemePreviewAppState extends State<ThemePreviewApp> {
  late var _currentScheme = widget.currentScheme;

  final pageController = PageController();

  late var _category = switch (_currentScheme?.schemeType) {
    SchemeType.basic => ThemeCategory.basic,
    SchemeType.builtIn => ThemeCategory.builtIn,
    SchemeType.accent => ThemeCategory.accent,
    SchemeType.image => ThemeCategory.image,
    SchemeType.custom => throw UnimplementedError(),
    null => ThemeCategory.builtIn,
  };

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        getSchemeFromColorSettings(_currentScheme) ?? widget.defaultScheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: colorScheme.brightness == Brightness.dark
          ? AppTheme.darkTheme(
              colorScheme: colorScheme,
              extendedColorScheme: staticDarkExtendedScheme,
            )
          : AppTheme.lightTheme(
              colorScheme: colorScheme,
              extendedColorScheme: staticLightExtendedScheme,
            ),
      home: Material(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.viewPaddingOf(context).top + 20,
                bottom: MediaQuery.sizeOf(context).height * _kMinSheetSize + 28,
              ),
              child: _buildPageView(colorScheme),
            ),
            Column(
              children: [
                Expanded(
                  child: DraggableScrollableSheet(
                    snap: true,
                    minChildSize: switch (_category) {
                      ThemeCategory.basic => 0.12,
                      ThemeCategory.builtIn => 0.18,
                      _ => _kMinSheetSize,
                    },
                    maxChildSize: _kMaxSheetSize,
                    initialChildSize: _kMinSheetSize,
                    builder: (context, scrollController) {
                      return ColoredBox(
                        color: context.colorScheme.surface,
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            const SliverDivider(
                              height: 1,
                            ),
                            const SliverSizedBox(
                              height: 8,
                            ),
                            SliverToBoxAdapter(
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.hintColor,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  height: 4,
                                  width: 40,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _buildOptions(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                CategoryToggleSwitch(
                  initialCategory: _category,
                  onToggle: (category) {
                    setState(() {
                      _category = category;
                    });
                  },
                ),
                SizedBox(
                  height: MediaQuery.viewPaddingOf(context).bottom,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          switch (_category) {
            ThemeCategory.basic => BasicColorSelector(
                onSchemeChanged: _onSchemeChanged,
                currentScheme: _currentScheme,
              ),
            ThemeCategory.builtIn => BuiltInColorSelector(
                onSchemeChanged: _onSchemeChanged,
                currentScheme: _currentScheme,
              ),
            ThemeCategory.accent => AccentColorSelector(
                onSchemeChanged: _onSchemeChanged,
                initialScheme: _currentScheme,
              ),
            ThemeCategory.image => ExtractImageColorSelector(
                onSchemeChanged: _onSchemeChanged,
                initialScheme: _currentScheme,
              ),
          },
        ],
      ),
    );
  }

  Column _buildPageView(
    ColorScheme colorScheme,
  ) {
    final pages = const [
      PreviewHome(),
      PreviewDetails(),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          (_currentScheme?.nickname ?? _currentScheme?.name ?? 'Default')
              .sentenceCase,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: PageView(
              controller: pageController,
              children: pages,
            ),
          ),
        ),
        SmoothPageIndicator(
          controller: pageController,
          count: pages.length,
          effect: WormEffect(
            activeDotColor: colorScheme.primary,
            dotColor: colorScheme.outlineVariant.withOpacity(0.25),
            dotHeight: 8,
            dotWidth: 16,
          ),
        ),
      ],
    );
  }

  void _onSchemeChanged(ColorSettings? settings) {
    setState(() {
      _currentScheme = settings;
      widget.onSchemeChanged(settings);
    });
  }
}
