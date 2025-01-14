// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:foundation/foundation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import '../../foundation/display.dart';
import '../app_theme.dart';
import '../theme_configs.dart';
import 'color_selector_accent.dart';
import 'color_selector_builtin.dart';
import 'page_preview.dart';
import 'widgets.dart';

const _kMinSheetSize = 0.3;
const _kMaxSheetSize = 0.75;

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
  final sheetController = DraggableScrollableController();

  final pageController = PageController();

  late var _category = switch (_currentScheme?.schemeType) {
    SchemeType.basic => ThemeCategory.basic,
    SchemeType.builtIn => ThemeCategory.builtIn,
    SchemeType.accent => ThemeCategory.accent,
    SchemeType.custom => throw UnimplementedError(),
    null => ThemeCategory.basic,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    sheetController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: viewPadding.top + 20,
                                bottom: !context.isLargeScreen
                                    ? MediaQuery.sizeOf(context).height *
                                            _kMinSheetSize -
                                        viewPadding.top -
                                        viewPadding.bottom
                                    : 0,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildPageView(colorScheme),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (context.isLargeScreen)
                      Container(
                        width: 460,
                        padding: EdgeInsets.only(
                          top: viewPadding.top + 40,
                        ),
                        child: SafeArea(
                          child: _buildSheetContent(colorScheme, null),
                        ),
                      ),
                  ],
                ),
                if (!context.isLargeScreen)
                  DraggableScrollableSheet(
                    controller: sheetController,
                    snap: true,
                    snapSizes: const [
                      _kMinSheetSize,
                      _kMaxSheetSize,
                    ],
                    snapAnimationDuration: const Duration(milliseconds: 200),
                    initialChildSize: _kMinSheetSize,
                    maxChildSize: _kMaxSheetSize,
                    minChildSize: _kMinSheetSize,
                    builder: (context, scrollController) {
                      return _buildSheetContent(colorScheme, scrollController);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(
    ColorScheme colorScheme,
    ScrollController? scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.hintColor,
            width: 0.25,
          ),
          left: BorderSide(
            color: colorScheme.hintColor,
            width: 0.25,
          ),
          right: BorderSide(
            color: colorScheme.hintColor,
            width: 0.25,
          ),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                if (!context.isLargeScreen)
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
                    top: 1,
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
  }

  Widget _buildOptions() {
    return Column(
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
    );
  }

  Column _buildPageView(
    ColorScheme colorScheme,
  ) {
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
