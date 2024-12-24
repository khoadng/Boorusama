// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../home/custom_home.dart';
import '../../../posts/details/custom_details.dart';
import '../../../theme.dart';
import '../../../theme/theme_configs.dart';
import '../../../theme/viewers/theme_viewer.dart';
import '../../../widgets/widgets.dart';
import '../booru_config.dart';
import '../data/booru_config_data.dart';
import 'details_layout_manager_page.dart';
import 'providers.dart';

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
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _HomeScreenSection(),
          Divider(),
          _ThemeSection(),
          Divider(),
          _CustomDetailsSection(),
        ],
      ),
    );
  }
}

class _CustomDetailsSection extends ConsumerStatefulWidget {
  const _CustomDetailsSection();

  @override
  ConsumerState<_CustomDetailsSection> createState() =>
      _CustomDetailsSectionState();
}

class _CustomDetailsSectionState extends ConsumerState<_CustomDetailsSection> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(initialBooruConfigProvider);
    final layout = ref.watch(
          editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
              .select((value) => value.layoutTyped),
        ) ??
        const LayoutConfigs.undefined();

    final uiBuilder = ref.watchBooruBuilder(config.auth)?.postDetailsUIBuilder;
    final details = layout.details ??
        convertDetailsParts(uiBuilder?.full.keys.toList() ?? []);
    final previewDetails = layout.previewDetails ??
        convertDetailsParts(uiBuilder?.preview.keys.toList() ?? []);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          title: const Text("Details' widgets"),
          trailing: uiBuilder != null
              ? TextButton(
                  child: const Text('Customize'),
                  onPressed: () => goToDetailsLayoutManagerPage(
                    context,
                    details: details,
                    availableParts: uiBuilder.full.keys.toSet(),
                    onDone: (parts) {
                      ref.editNotifier.updateLayout(
                        layout.copyWith(
                          details: () => parts,
                        ),
                      );
                    },
                  ),
                )
              : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          title: const Text('Preview widgets'),
          trailing: uiBuilder != null
              ? TextButton(
                  child: const Text('Customize'),
                  onPressed: () => goToDetailsLayoutManagerPage(
                    context,
                    details: previewDetails,
                    availableParts: uiBuilder.buildablePreviewParts.toSet(),
                    onDone: (parts) {
                      ref.editNotifier.updateLayout(
                        layout.copyWith(
                          previewDetails: () => parts,
                        ),
                      );
                    },
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.themeTyped),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SwitchListTile(
          title: const Text('Custom theme'),
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
              .select((value) => value.layoutTyped),
        ) ??
        const LayoutConfigs.undefined();
    final data = booruBuilder?.customHomeViewBuilders ?? kDefaultAltHomeView;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text('Home screen'),
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
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(_describeView(data, value)).tr(),
              ),
            )
            .toList(),
      ),
    );
  }

  String _describeView(
    Map<CustomHomeViewKey, CustomHomeDataBuilder> data,
    CustomHomeViewKey viewKey,
  ) =>
      data[viewKey]?.displayName ?? 'Unknown';
}

class ThemeListTile extends ConsumerWidget {
  const ThemeListTile({
    required this.colorSettings, required this.onThemeUpdated, super.key,
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
    required this.onThemeUpdated, required this.colorSettings, super.key,
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
    required this.colorSettings, required this.saveButton, super.key,
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
