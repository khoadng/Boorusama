// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'booru_bottom_sheet.dart';

class SettingsSelector<T> extends StatelessWidget {
  const SettingsSelector({
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    super.key,
    this.title,
    this.subtitleBuilder,
  });

  final T value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final String Function(T)? subtitleBuilder;
  final ValueChanged<T> onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          showBooruModalBottomSheet(
            context: context,
            builder: (context) => SettingsSheet<T>(
              title: title,
              value: value,
              items: items,
              itemBuilder: itemBuilder,
              subtitleBuilder: subtitleBuilder,
              onChanged: onChanged,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          child: Row(
            children: [
              Text(itemBuilder(value)),
              Icon(
                Symbols.keyboard_arrow_down,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSheet<T> extends StatelessWidget {
  const SettingsSheet({
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    super.key,
    this.title,
    this.subtitleBuilder,
  });

  final T value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final String Function(T)? subtitleBuilder;
  final ValueChanged<T> onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ...items.map(
          (item) => SettingsOptionTile<T>(
            selected: value == item,
            title: itemBuilder(item),
            subtitle: subtitleBuilder?.call(item),
            onTap: () {
              onChanged(item);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class SettingsOptionTile<T> extends StatelessWidget {
  const SettingsOptionTile({
    required this.title,
    super.key,
    this.subtitle,
    this.selected = false,
    this.onTap,
  });

  final bool selected;
  final void Function()? onTap;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: EdgeInsets.all(12 + (selected ? 0 : 1.5)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: borderRadius,
            border: Border.all(
              width: selected ? 1.5 : 0.25,
              color: selected
                  ? colorScheme.onSurface
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsNavigationTile<T> extends StatelessWidget {
  const SettingsNavigationTile({
    required this.title,
    required this.value,
    required this.valueBuilder,
    required this.onTap,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final String Function(T) valueBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valueBuilder(value),
            style: TextStyle(
              color: theme.hintColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Symbols.chevron_right,
            size: 20,
            color: theme.iconTheme.color,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class SettingsSelectionSheet<T> extends StatelessWidget {
  const SettingsSelectionSheet({
    required this.title,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    super.key,
    this.subtitleBuilder,
  });

  final String title;
  final T value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final String Function(T)? subtitleBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items.map(
          (item) => SettingsOptionTile<T>(
            selected: value == item,
            title: itemBuilder(item),
            subtitle: subtitleBuilder?.call(item),
            onTap: () {
              onChanged(item);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
