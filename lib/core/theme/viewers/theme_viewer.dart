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

// Project imports:


const _kMinSheetSize = 0.24;
const _kMaxSheetSize = 0.65;

class ThemePreviewApp extends StatefulWidget {
  const ThemePreviewApp({
    required this.defaultScheme, required this.currentScheme, required this.onSchemeChanged, super.key,
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
                        120,
                  ),
                  child: _buildPageView(colorScheme),
                ),
                Column(
                  children: [
                    Expanded(
                      child: DraggableScrollableSheet(
                        snap: true,
                        minChildSize: switch (_category) {
                          ThemeCategory.accent => 0.3,
                          _ => _kMinSheetSize,
                        },
                        maxChildSize: _kMaxSheetSize,
                        initialChildSize: switch (_category) {
                          ThemeCategory.accent => 0.3,
                          _ => _kMinSheetSize,
                        },
                        builder: (context, scrollController) {
                          return ColoredBox(
                            color: Theme.of(context).colorScheme.surface,
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
          child: Transform.scale(
            scale: 0.88,
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
            dotColor: colorScheme.outlineVariant.withValues(alpha: 0.25),
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
