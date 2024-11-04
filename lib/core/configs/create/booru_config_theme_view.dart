// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import 'package:boorusama/widgets/widgets.dart';

class BooruConfigThemeView extends ConsumerWidget {
  const BooruConfigThemeView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BooruConfigDataProvider(
            builder: (config) => SwitchListTile(
              title: const Text("Custom theme"),
              value: config.themeTyped?.enable ?? false,
              onChanged: (value) => ref.editNotifier.updateTheme(
                config.themeTyped?.copyWith(enable: value),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          BooruConfigDataProvider(
            builder: (config) => GrayedOut(
              grayedOut: config.themeTyped?.enable != true,
              child: ThemeListTile(
                colorSettings: config.themeTyped?.colors,
                onThemeUpdated: (colors) {
                  ref.editNotifier.updateTheme(
                    ThemeConfigs(
                      colors: colors,
                      enable: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeListTile extends ConsumerWidget {
  const ThemeListTile({
    super.key,
    required this.colorSettings,
    required this.onThemeUpdated,
  });

  final ColorSettings? colorSettings;
  final void Function(ColorSettings? colors) onThemeUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text("Colors"),
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
    return context.navigator.push(
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
    super.key,
    required this.onThemeUpdated,
    required this.colorSettings,
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
          context.navigator.pop();
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
          context.navigator.pop();
        },
        child: const Text('Upgrade'),
      ),
    );
  }
}

class ThemePreviewView extends ConsumerStatefulWidget {
  const ThemePreviewView({
    super.key,
    required this.colorSettings,
    required this.saveButton,
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
                  context.navigator.pop();
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
