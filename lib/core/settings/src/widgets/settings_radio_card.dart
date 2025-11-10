// Flutter imports:
import 'package:flutter/material.dart';

class SettingsRadioCard extends StatelessWidget {
  const SettingsRadioCard({
    required this.title,
    required this.entries,
    super.key,
    this.subtitle,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final List<Widget> entries;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            vertical: 8,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: entry,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRadioCardEntry<T> extends StatelessWidget {
  const SettingsRadioCardEntry({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onSelected,
    super.key,
  });

  final T value;
  final T groupValue;
  final String title;
  final String subtitle;
  final void Function(T? value) onSelected;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
      child: RadioListTile<T>(
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: EdgeInsets.zero,
        value: value,
        subtitle: Text(subtitle),
        title: Text(title),
      ),
    );
  }
}
