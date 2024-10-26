// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'color_selector_builtin.dart';
import 'color_selector_accent.dart';
import 'color_selector_image.dart';
import 'page_preview.dart';
import 'widgets.dart';

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
    SchemeType.builtIn => ThemeCategory.builtIn,
    SchemeType.accent => ThemeCategory.accent,
    SchemeType.image => ThemeCategory.image,
    _ => ThemeCategory.builtIn,
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

    final pages = [
      PreviewHome(
        colorScheme: colorScheme,
      ),
      PreviewDetails(
        colorScheme: colorScheme,
      ),
    ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.viewPaddingOf(context).top + 20,
                    ),
                    child: Text(
                      (_currentScheme?.nickname ??
                              _currentScheme?.name ??
                              'Default')
                          .sentenceCase,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Flexible(
                    child: LayoutBuilder(
                      builder: (_, c) => Container(
                        constraints: BoxConstraints(
                          maxHeight: 600,
                        ),
                        child: PageView(
                          controller: pageController,
                          children: pages,
                        ),
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
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  switch (_category) {
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
                  Padding(
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
                  SizedBox(
                    height: MediaQuery.viewPaddingOf(context).bottom,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSchemeChanged(ColorSettings? settings) {
    setState(() {
      _currentScheme = settings;
      widget.onSchemeChanged(settings);
    });
  }
}
