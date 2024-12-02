// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'create.dart';

class DefaultBooruConfigLayoutView extends ConsumerWidget {
  const DefaultBooruConfigLayoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BooruConfigLayoutView();
  }
}

class BooruConfigLayoutView extends ConsumerWidget {
  const BooruConfigLayoutView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _ThemeSection(),
          const Divider(),
          const _HomeScreenSection(),
          const Divider(),
          const _CustomDetailsSection(),
        ],
      ),
    );
  }
}

class _CustomDetailsSection extends ConsumerWidget {
  const _CustomDetailsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final layout = ref.watch(
            editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
                .select((value) => value.layoutTyped)) ??
        LayoutConfigs.undefined();

    final uiBuilder = ref.watchBooruBuilder(config.auth)?.postDetailsUIBuilder;
    final details = layout.details ??
        convertDetailsParts(uiBuilder?.full.keys.toList() ?? []);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Information widgets"),
            trailing: uiBuilder != null
                ? TextButton(
                    child: const Text('Customize'),
                    onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => CustomDetailsChooserPage(
                          availableParts: uiBuilder.full.keys.toList(),
                          selectedParts: layout.getParsedParts()?.toList(),
                          onDone: (parts) => ref.editNotifier.updateLayout(
                            layout.copyWith(
                              details: () => convertDetailsParts(parts),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        if (uiBuilder != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ReorderableColumn(
              onReorder: (int oldIndex, int newIndex) {
                final newDetails = details.toList();

                final item = newDetails.removeAt(oldIndex);
                newDetails.insert(newIndex, item);

                ref.editNotifier.updateLayout(
                  layout.copyWith(details: () => newDetails),
                );
              },
              children: details
                  .map(
                    (e) => Container(
                      key: ValueKey(e.name),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 0.75,
                        ),
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.drag_indicator,
                          color: Theme.of(context).colorScheme.hintColor,
                        ),
                        trailing: BooruPopupMenuButton(
                          onSelected: (value) {
                            if (value == 'remove') {
                              if (details.length == 1) {
                                showErrorToast(
                                  context,
                                  'At least one item is required',
                                );
                                return;
                              }

                              ref.editNotifier.updateLayout(
                                layout.copyWith(
                                  details: () => details
                                      .where((element) => element != e)
                                      .toList(),
                                ),
                              );
                            }
                          },
                          itemBuilder: {
                            'remove': const Text('Remove'),
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        title: Text(e.name),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(editBooruConfigProvider(
      ref.watch(editBooruConfigIdProvider),
    ).select((value) => value.themeTyped));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SwitchListTile(
          title: const Text("Custom theme"),
          value: theme?.enable ?? false,
          onChanged: (value) => ref.editNotifier.updateTheme(
            theme?.copyWith(enable: value),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        GrayedOut(
          grayedOut: theme?.enable != true,
          child: ThemeListTile(
            colorSettings: theme?.colors,
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
      ],
    );
  }
}

class _HomeScreenSection extends ConsumerWidget {
  const _HomeScreenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final booruBuilder = ref.watchBooruBuilder(config.auth);
    final layout = ref.watch(
            editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
                .select((value) => value.layoutTyped)) ??
        LayoutConfigs.undefined();
    final data = booruBuilder?.customHomeViewBuilders ?? kDefaultAltHomeView;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text("Home screen"),
      subtitle: const Text(
        'Change the view of the home screen',
      ),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: layout.home,
        onChanged: (value) => ref.editNotifier.updateLayout(
          layout.copyWith(home: () => value),
        ),
        items: data.keys
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(_describeView(data, value)).tr(),
                ))
            .toList(),
      ),
    );
  }

  String _describeView(Map<CustomHomeViewKey, CustomHomeDataBuilder> data,
          CustomHomeViewKey viewKey) =>
      data[viewKey]?.displayName ?? 'Unknown';
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
