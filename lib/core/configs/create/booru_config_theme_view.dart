// Flutter imports:
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/utils/flutter_utils.dart';
import 'package:material_symbols_icons/symbols.dart';

final _currentSelectColorSchemeProvider =
    StateProvider.autoDispose<ColorSettings?>(
  (ref) {
    return ref.watch(themeConfigsProvider)?.colors;
  },
  dependencies: [
    themeConfigsProvider,
  ],
);

class BooruConfigThemeView extends ConsumerWidget {
  const BooruConfigThemeView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = ref.watch(colorSchemeProvider);
    final colors = ref.watch(_currentSelectColorSchemeProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Color scheme"),
            subtitle: Text(
              colors?.nickname ?? 'Default',
            ),
            onTap: () async {
              _customizeTheme(context, fallback, colors, ref);
            },
            trailing: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onPressed: () => _customizeTheme(context, fallback, colors, ref),
              child: const Text('Customize'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _customizeTheme(BuildContext context, ColorScheme fallback,
      ColorSettings? colors, WidgetRef ref) {
    return context.navigator.push(
      CupertinoPageRoute(
        builder: (context) => Material(
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
                          ref
                              .read(_currentSelectColorSchemeProvider.notifier)
                              .state = newScheme;
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
                      final colors =
                          ref.read(_currentSelectColorSchemeProvider);

                      ref.updateTheme(
                        ThemeConfigs(
                          colors: colors,
                          enable: true,
                        ),
                      );
                      context.navigator.pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
