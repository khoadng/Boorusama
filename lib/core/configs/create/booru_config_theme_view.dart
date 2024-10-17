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
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Color scheme"),
            subtitle: BooruConfigDataProvider(
              builder: (configData) => Text(
                configData.themeTyped?.colors?.nickname ?? 'Default',
              ),
            ),
            onTap: () {
              _customizeTheme(ref, context);
            },
            trailing: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onPressed: () => _customizeTheme(ref, context),
              child: const Text('Customize'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _customizeTheme(
    WidgetRef ref,
    BuildContext context,
  ) {
    final colors = ref.read(themeConfigsProvider)?.colors;

    return context.navigator.push(
      CupertinoPageRoute(
        builder: (context) => ThemePreviewView(
          colorSettings: colors,
          onThemeUpdated: (colors) {
            ref.updateTheme(
              ThemeConfigs(
                colors: colors,
                enable: true,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ThemePreviewView extends ConsumerStatefulWidget {
  const ThemePreviewView({
    super.key,
    required this.colorSettings,
    required this.onThemeUpdated,
  });

  final ColorSettings? colorSettings;
  final void Function(ColorSettings? colors) onThemeUpdated;

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
              child: TextButton(
                onPressed: () {
                  widget.onThemeUpdated(colors);
                  context.navigator.pop();
                },
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
