// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'color_selector.dart';
import 'page_preview.dart';

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.6,
                constraints: const BoxConstraints(
                  maxHeight: 600,
                ),
                child: PageView(
                  controller: pageController,
                  children: pages,
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
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        (_currentScheme?.nickname ??
                                _currentScheme?.name ??
                                'Default')
                            .sentenceCase,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
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
                    const SizedBox(height: 24),
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
                    }
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
