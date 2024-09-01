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
            title: const Text("Color Scheme"),
            subtitle: const Text(
              'Change the color scheme of the app for this particular profile.',
            ),
            onTap: () async {
              context.navigator.push(
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
                                        .read(_currentSelectColorSchemeProvider
                                            .notifier)
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
            },
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors?.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors?.primary ?? Colors.black,
                  width: 2,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("App's home screen"),
            subtitle: const Text(
              'Customize the default screen of the app for this profile.',
            ),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: 'Default',
              onChanged: (value) {
                print(value);
              },
              items: [
                'Default',
                'Search',
              ]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
