// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import '../../widgets/widgets.dart';
import '../app_theme.dart';
import '../theme_configs.dart';
import 'color_selector_accent.dart';
import 'color_selector_builtin.dart';
import 'page_preview.dart';
import 'widgets.dart';

const _kMinSheetSize = 0.1;
const _kMiddleSheetSize = 0.4;
const _kMaxSheetSize = 0.7;

class ThemePreviewApp extends StatefulWidget {
  const ThemePreviewApp({
    required this.defaultScheme,
    required this.currentScheme,
    required this.onSchemeChanged,
    super.key,
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
    SchemeType.custom => throw UnimplementedError(),
    null => ThemeCategory.basic,
  };

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //FIXME: potential performance issue due to this widget being rebuilt multiple times
    return DynamicColorBuilder(
      builder: (light, dark) {
        final systemDarkMode =
            MediaQuery.platformBrightnessOf(context) == Brightness.dark;

        final colorScheme = getSchemeFromColorSettings(
              _currentScheme,
              dynamicLightScheme: light,
              dynamicDarkScheme: dark,
              systemDarkMode: systemDarkMode,
            ) ??
            widget.defaultScheme;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeFrom(
            null,
            colorScheme: colorScheme,
            systemDarkMode: systemDarkMode,
          ),
          home: Material(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.viewPaddingOf(context).top + 20,
                    bottom: MediaQuery.sizeOf(context).height * _kMinSheetSize +
                        160,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildPageView(colorScheme),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: DraggableScrollableSheet(
                    snap: true,
                    snapSizes: const [
                      _kMinSheetSize,
                      _kMiddleSheetSize,
                      _kMaxSheetSize,
                    ],
                    snapAnimationDuration: const Duration(milliseconds: 200),
                    initialChildSize: _kMiddleSheetSize,
                    maxChildSize: _kMaxSheetSize,
                    minChildSize: _kMinSheetSize,
                    builder: (context, scrollController) {
                      return ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60,
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: CategoryToggleSwitch(
                                        initialCategory: _category,
                                        onToggle: (category) {
                                          setState(() {
                                            _category = category;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 20,
                                      left: 12,
                                      right: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: colorScheme.outlineVariant,
                                          width: 0.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomScrollView(
                                      slivers: [
                                        SliverList.list(
                                          children: [
                                            _buildOptions(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          },
        ],
      ),
    );
  }

  Column _buildPageView(
    ColorScheme colorScheme,
  ) {
    const pages = [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 36,
        ),
        child: PreviewHome(),
      ),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 36,
        ),
        child: PreviewDetails(),
      ),
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
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: SmoothPageIndicator(
            controller: pageController,
            count: pages.length,
            effect: WormEffect(
              activeDotColor: colorScheme.primary,
              dotColor: colorScheme.outlineVariant.withValues(alpha: 0.25),
              dotHeight: 8,
              dotWidth: 16,
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: pageController,
            children: pages,
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
