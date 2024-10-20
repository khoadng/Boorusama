// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
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
  'grey': Colors.grey,
  'blueGrey': Colors.blueGrey,
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
    final colorScheme = currentScheme?.toColorScheme() ??
        preDefinedColorSettings.first.toColorScheme()!;

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Wrap(
            runSpacing: 8,
            children: [
              ...preDefinedColorSettings.map((e) {
                final selected = e == currentScheme;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: _PreviewColor(
                    color: e,
                    onTap: () {
                      onSchemeChanged(e);
                    },
                    colorScheme: colorScheme,
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
  late var _currentScheme = _settings?.toColorScheme();
  late var _isDark = widget.initialScheme?.brightness == Brightness.dark;

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

enum ThemeCategory {
  builtIn,
  accent,
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
        fixedWidth: 120,
        segments: {
          ThemeCategory.builtIn: 'Built-in',
          ThemeCategory.accent: 'Accent',
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}

bool _sameish(Color a, Color b, [int threshold = 10]) {
  return (a.red - b.red).abs() < threshold &&
      (a.green - b.green).abs() < threshold &&
      (a.blue - b.blue).abs() < threshold;
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

class _PreviewColor extends StatelessWidget {
  const _PreviewColor({
    required this.color,
    required this.onTap,
    required this.colorScheme,
    required this.selected,
  });

  final ColorSettings? color;
  final ColorScheme colorScheme;
  final void Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = color;

    final sameColorWithSurface = c != null &&
        _sameish(c.surface ?? Colors.transparent, colorScheme.surface, 20);

    if (c == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.onSurface,
              width: selected ? 2.5 : 1.3,
            ),
          ),
          child: Icon(
            Icons.refresh,
            color: colorScheme.onSurface,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: c.surface ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : sameColorWithSurface
                    ? colorScheme.onSurface
                    : Colors.transparent,
            width: selected
                ? 2.5
                : sameColorWithSurface
                    ? 1.3
                    : 0,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check,
                color: colorScheme.onSurface,
              )
            : null,
      ),
    );
  }
}
