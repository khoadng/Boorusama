// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../types/settings_search_entry.dart';
import 'settings_page_scaffold.dart';

class SettingsSearchResultTile extends StatelessWidget {
  const SettingsSearchResultTile({
    required this.entry,
    required this.selected,
    required this.keyboardFocused,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final SettingsSearchEntry entry;
  final bool compact;
  final bool selected;
  final bool keyboardFocused;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Kurumi.themeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      child: Material(
        color: selected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: keyboardFocused
              ? BorderSide(color: theme.colorScheme.primary)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: compact,
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 0 : 4,
          ),
          selected: selected,
          selectedColor: theme.colorScheme.onPrimaryContainer,
          leading: compact
              ? null
              : IconTheme.merge(
                  data: IconThemeData(
                    size: 20,
                    color: selected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.outline,
                  ),
                  child: SettingEntryIcon(icon: entry.category.icon),
                ),
          minLeadingWidth: 24,
          horizontalTitleGap: 12,
          title: Text(
            entry.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.breadcrumb,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.outline,
                ),
              ),
              if (entry.status case final status?)
                Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    height: 1.4,
                    color: selected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          trailing: compact
              ? null
              : Icon(
                  Symbols.chevron_right,
                  size: 18,
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.outline,
                ),
          onTap: onTap,
        ),
      ),
    );
  }
}
