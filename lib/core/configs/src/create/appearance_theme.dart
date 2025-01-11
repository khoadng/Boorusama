// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../theme.dart';
import '../../../theme/theme_configs.dart';
import '../../../theme/viewers/theme_viewer.dart';
import '../../../widgets/widgets.dart';
import '../data/booru_config_data.dart';
import 'providers.dart';

class ThemeListTile extends ConsumerWidget {
  const ThemeListTile({
    required this.colorSettings,
    required this.onThemeUpdated,
    super.key,
  });

  final ColorSettings? colorSettings;
  final void Function(ColorSettings? colors) onThemeUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text('Colors'),
      subtitle: Text(
        colorSettings?.nickname ?? 'Default',
      ),
      onTap: () {
        _customizeTheme(ref, context);
      },
      trailing: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
        ),
        onPressed: () => _customizeTheme(ref, context),
        child: const Text('Customize'),
      ),
    );
  }

  Future<void> _customizeTheme(
    WidgetRef ref,
    BuildContext context,
  ) {
    return Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ThemePreviewRealView(
          colorSettings: colorSettings,
          onThemeUpdated: (colors) {
            onThemeUpdated(colors);
          },
        ),
      ),
    );
  }
}

class ThemePreviewRealView extends StatefulWidget {
  const ThemePreviewRealView({
    required this.onThemeUpdated,
    required this.colorSettings,
    super.key,
  });

  final void Function(ColorSettings? colors) onThemeUpdated;
  final ColorSettings? colorSettings;

  @override
  State<ThemePreviewRealView> createState() => _ThemePreviewRealViewState();
}

class _ThemePreviewRealViewState extends State<ThemePreviewRealView> {
  late var _colors = widget.colorSettings;

  @override
  Widget build(BuildContext context) {
    return ThemePreviewView(
      colorSettings: widget.colorSettings,
      onColorChanged: (colors) {
        setState(() {
          _colors = colors;
        });
      },
      saveButton: TextButton(
        onPressed: () {
          widget.onThemeUpdated(_colors);
          Navigator.of(context).pop();
        },
        child: const Text('Save'),
      ),
    );
  }
}

class ThemePreviewPreviewView extends StatelessWidget {
  const ThemePreviewPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemePreviewView(
      colorSettings: null,
      saveButton: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Upgrade'),
      ),
    );
  }
}

class ThemePreviewView extends ConsumerStatefulWidget {
  const ThemePreviewView({
    required this.colorSettings,
    required this.saveButton,
    super.key,
    this.onColorChanged,
  });

  final Widget saveButton;
  final ColorSettings? colorSettings;
  final void Function(ColorSettings? colors)? onColorChanged;

  @override
  ConsumerState<ThemePreviewView> createState() => _ThemePreviewViewState();
}

class _ThemePreviewViewState extends ConsumerState<ThemePreviewView> {
  late ColorSettings? colors = widget.colorSettings;

  @override
  Widget build(BuildContext context) {
    final fallback = ref.watch(colorSchemeProvider);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ThemePreviewApp(
                    defaultScheme: fallback,
                    currentScheme: colors,
                    onSchemeChanged: (newScheme) {
                      setState(() {
                        colors = newScheme;
                        widget.onColorChanged?.call(newScheme);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // close button
          Positioned(
            top: 0,
            left: 4,
            child: SafeArea(
              child: CircularIconButton(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Symbols.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 4,
            child: SafeArea(
              child: widget.saveButton,
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeConfigsPage extends ConsumerWidget {
  const ThemeConfigsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.themeTyped),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: _ThemeSection(
        theme: theme,
        onThemeUpdated: (theme) {
          ref.editNotifier.updateTheme(theme);
        },
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({
    required this.theme,
    required this.onThemeUpdated,
  });

  final ThemeConfigs? theme;
  final void Function(ThemeConfigs? theme) onThemeUpdated;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('Turn on'),
              subtitle: const Text(
                "Override the global theme using this profile's theme",
              ),
              value: theme?.enable ?? false,
              onChanged: (value) => onThemeUpdated(
                theme?.copyWith(enable: value),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            GrayedOut(
              grayedOut: theme?.enable != true,
              child: ThemeListTile(
                colorSettings: theme?.colors,
                onThemeUpdated: (colors) {
                  onThemeUpdated(
                    ThemeConfigs(
                      colors: colors,
                      enable: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
