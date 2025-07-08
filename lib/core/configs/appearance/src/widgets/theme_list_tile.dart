// Flutter imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../theme/theme_configs.dart';
import '../../../../theme/viewers/widgets.dart';
import '../types/enums.dart';

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
      title: Text('Colors'.hc),
      subtitle: Text(
        colorSettings?.nickname ?? 'Default'.hc,
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
        child: Text('Customize'.hc),
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
