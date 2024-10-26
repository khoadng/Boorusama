// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:boorusama/dart.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

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
    final colorScheme = getSchemeFromPredefined(currentScheme?.name) ??
        getSchemeFromPredefined(preDefinedColorSettings.first.name);

    if (colorScheme == null) {
      return Center(
        child: Text('Error: Color scheme not found'),
      );
    }

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Wrap(
            runSpacing: 8,
            children: [
              ...preDefinedColorSettings.map((e) {
                final selected = e.name == currentScheme?.name;
                final cs = getSchemeFromPredefined(e.name);

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
  late var _currentScheme = getSchemeFromColorSettings(widget.initialScheme);
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
              ...primaryColors.keys.map(
                (e) {
                  final color = primaryColors[e]!;
                  final cs = ColorScheme.fromSeed(
                    seedColor: color,
                    brightness: _isDark ? Brightness.dark : Brightness.light,
                  );

                  final selected = _settings?.name == color.hexWithoutAlpha;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: _PreviewBasicColor(
                      onTap: () {
                        setState(() {
                          _settings = ColorSettings.fromAccentColor(
                            color,
                            brightness:
                                _isDark ? Brightness.dark : Brightness.light,
                          );
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

                _settings = st.copyWith(
                  brightness: value ? Brightness.dark : Brightness.light,
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
  // ignore: unused_field
  late var _currentScheme = getSchemeFromColorSettings(widget.initialScheme);

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
            )
          else if (widget.initialScheme?.colorScheme != null)
            Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.initialScheme?.colorScheme?.primary,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipPath(
                      clipper: SplashClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget
                              .initialScheme?.colorScheme?.secondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
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
            ColorVariantSelector(
              variant: _variant,
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
            widget.initialScheme?.colorScheme != null
                ? 'Change image'
                : 'Pick an image',
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

    final settings = ColorSettings.fromImage(
      cs,
      brightness: brightness,
    );

    setState(() {
      _imagePath = path;
      _settings = settings;
      _currentScheme = cs;
      widget.onSchemeChanged(_settings);
    });
  }
}

class ColorVariantSelector extends StatelessWidget {
  const ColorVariantSelector({
    super.key,
    required this.variant,
    required this.onChanged,
  });

  final DynamicSchemeVariant variant;
  final void Function(DynamicSchemeVariant? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text('Variants'),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: variant,
        onChanged: onChanged,
        items: DynamicSchemeVariant.values
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.name.sentenceCase),
                ))
            .toList(),
      ),
    );
  }
}

enum ThemeCategory {
  builtIn,
  accent,
  image,
}

class SplashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
    required this.initialCategory,
  });

  final void Function(ThemeCategory category) onToggle;
  final ThemeCategory initialCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: initialCategory,
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
