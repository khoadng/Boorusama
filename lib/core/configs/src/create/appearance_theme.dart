// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../../theme/theme_configs.dart';
import '../../../theme/viewers/widgets.dart';
import '../../../widgets/widgets.dart';
import '../data/booru_config_data.dart';
import 'providers.dart';

enum ThemeUpdateMethod {
  applyDirectly,
  saveAndUpdateLater,
}

class ThemeListTile extends ConsumerWidget {
  const ThemeListTile({
    required this.colorSettings,
    required this.onThemeUpdated,
    required this.updateMethod,
    super.key,
  });

  final ColorSettings? colorSettings;
  final void Function(ColorSettings? colors) onThemeUpdated;
  final ThemeUpdateMethod updateMethod;

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
        builder: (context) => ThemePreviewer(
          colorSettings: colorSettings,
          onThemeUpdated: (colors) {
            onThemeUpdated(colors);
          },
          updateMethod: updateMethod,
        ),
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
          showSimpleSnackBar(
            context: context,
            duration: const Duration(seconds: 3),
            content: const Text(
              'Your theme will be applied when you save this profile',
            ),
          );
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
                updateMethod: ThemeUpdateMethod.saveAndUpdateLater,
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
