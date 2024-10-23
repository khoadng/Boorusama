// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

final _kPrimaryColors = {
  'red': Colors.red,
  'pink': Colors.pink,
  'purple': Colors.purple,
  'deepPurple': Colors.deepPurple,
  'indigo': Colors.indigo,
  'blue': Colors.blue,
  'lightBlue': Colors.lightBlue,
  'cyan': Colors.cyan,
  'teal': Colors.teal,
  'green': Colors.green,
  'lightGreen': Colors.lightGreen,
  'lime': Colors.lime,
  'yellow': Colors.yellow,
  'amber': Colors.amber,
  'orange': Colors.orange,
  'deepOrange': Colors.deepOrange,
  'brown': Colors.brown,
};

class BuiltInColorSelector extends StatelessWidget {
  const BuiltInColorSelector({
    super.key,
    required this.onSchemeChanged,
    required this.currentScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? currentScheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = currentScheme?.colorScheme ??
        preDefinedColorSettings.first.colorScheme!;

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Wrap(
            runSpacing: 8,
            children: [
              ...preDefinedColorSettings.map((e) {
                final selected = e == currentScheme;
                final cs = e.colorScheme;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: _PreviewBasicColor(
                    primary: cs?.primary ?? Colors.transparent,
                    onPrimary: cs?.onPrimary ?? colorScheme.onPrimary,
                    onSurface: cs?.onSurface ?? colorScheme.onSurface,
                    onTap: () {
                      onSchemeChanged(e);
                    },
                    selected: selected,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class AccentColorSelector extends StatefulWidget {
  const AccentColorSelector({
    super.key,
    required this.onSchemeChanged,
    this.initialScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? initialScheme;

  @override
  State<AccentColorSelector> createState() => _AccentColorSelectorState();
}

class _AccentColorSelectorState extends State<AccentColorSelector> {
  late var _settings = widget.initialScheme;
  late var _currentScheme = _settings?.colorScheme;
  late var _isDark =
      widget.initialScheme?.colorScheme?.brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Wrap(
            runSpacing: 8,
            children: [
              ..._kPrimaryColors.keys.map(
                (e) {
                  final color = _kPrimaryColors[e]!;
                  final cs = ColorScheme.fromSeed(
                    seedColor: color,
                    brightness: _isDark ? Brightness.dark : Brightness.light,
                  );
                  final settings = ColorSettings.fromCustomScheme(
                    'basic-$e-${_isDark ? 'dark' : 'light'}',
                    cs,
                    nickname: e,
                  );

                  final selected = _settings?.name == settings?.name;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: _PreviewBasicColor(
                      onTap: () {
                        setState(() {
                          _settings = settings;
                          _currentScheme = cs;
                          widget.onSchemeChanged(_settings);
                        });
                      },
                      selected: selected,
                      primary: color,
                      onPrimary: cs.onPrimary,
                      onSurface: cs.onSurface,
                    ),
                  );
                },
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: _isDark,
            onChanged: (value) {
              final cs = _currentScheme;
              final st = _settings;

              if (cs == null) return;
              if (st == null) return;

              setState(() {
                _isDark = value;

                _currentScheme = ColorScheme.fromSeed(
                  seedColor: cs.primary,
                  brightness: value ? Brightness.dark : Brightness.light,
                );

                // change name to reflect the new brightness
                // basic-red-light -> basic-red-dark
                final newSchemeName = st.name.replaceFirst(
                  value ? '-light' : '-dark',
                  value ? '-dark' : '-light',
                );

                _settings = ColorSettings.fromCustomScheme(
                  newSchemeName,
                  _currentScheme,
                  nickname: st.nickname,
                );
                widget.onSchemeChanged(_settings);
              });
            },
          ),
        ],
      ),
    );
  }
}

class ExtractImageColorSelector extends StatefulWidget {
  const ExtractImageColorSelector({
    super.key,
    required this.onSchemeChanged,
    this.initialScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? initialScheme;

  @override
  State<ExtractImageColorSelector> createState() =>
      _ExtractImageColorSelectorState();
}

class _ExtractImageColorSelectorState extends State<ExtractImageColorSelector> {
  late var _settings = widget.initialScheme;
  late var _isDark =
      widget.initialScheme?.colorScheme?.brightness == Brightness.dark;
  var _imagePath = '';
  var _variant = DynamicSchemeVariant.tonalSpot;

  Future<void> _pickFile({
    required void Function(String path) onPick,
  }) {
    return pickSingleFilePathToastOnError(
      context: context,
      onPick: (path) {
        onPick(path);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          if (_imagePath.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Image.file(
                File(_imagePath),
                width: 120,
                height: 120,
              ),
            ),
          _buildPickButton(context),
          if (_imagePath.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(
                top: 12,
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                value: _isDark,
                onChanged: (value) async {
                  setState(() {
                    _isDark = value;
                  });

                  await _updateScheme(
                    _imagePath,
                    _variant,
                    value ? Brightness.dark : Brightness.light,
                  );
                },
              ),
            ),
          if (_imagePath.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: const Text('Variants'),
              trailing: OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: _variant,
                onChanged: (value) async {
                  if (value == null) return;

                  await _updateScheme(
                    _imagePath,
                    value,
                    _isDark ? Brightness.dark : Brightness.light,
                  );

                  setState(() {
                    _variant = value;
                  });
                },
                items: DynamicSchemeVariant.values
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.name.sentenceCase),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickButton(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.secondaryContainer,
          ),
          onPressed: () {
            _pickFile(
              onPick: (path) async {
                await _updateScheme(
                  path,
                  _variant,
                  _isDark ? Brightness.dark : Brightness.light,
                );
              },
            );
          },
          child: Text(
            'Pick an image',
            style: TextStyle(
              color: context.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateScheme(
    String path,
    DynamicSchemeVariant variant,
    Brightness brightness,
  ) async {
    final imageProvider = FileImage(
      File(path),
    );

    final cs = await ColorScheme.fromImageProvider(
      provider: imageProvider,
      dynamicSchemeVariant: variant,
      brightness: brightness,
    );

    final settings = ColorSettings.fromCustomScheme(
      'image-pick',
      cs,
      nickname: 'Image',
    );

    setState(() {
      _imagePath = path;
      _settings = settings;
      widget.onSchemeChanged(_settings);
    });
  }
}

enum ThemeCategory {
  builtIn,
  accent,
  image,
}

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(ThemeCategory category) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: ThemeCategory.builtIn,
        segments: {
          ThemeCategory.builtIn: 'Built-in',
          ThemeCategory.accent: 'Accent',
          ThemeCategory.image: 'Image',
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}

class _PreviewBasicColor extends StatelessWidget {
  const _PreviewBasicColor({
    required this.primary,
    required this.onPrimary,
    required this.onSurface,
    required this.selected,
    required this.onTap,
  });

  final Color primary;
  final Color onPrimary;
  final Color onSurface;
  final void Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: selected
            ? Icon(
                Icons.check,
                color: onPrimary,
                size: 36,
              )
            : null,
      ),
    );
  }
}
