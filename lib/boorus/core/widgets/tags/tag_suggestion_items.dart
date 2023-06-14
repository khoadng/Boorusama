// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/functional.dart';

class TagSuggestionItems extends ConsumerWidget {
  const TagSuggestionItems({
    super.key,
    required IList<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
    this.backgroundColor,
    this.textColorBuilder,
  }) : _tags = tags;

  final IList<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final Color? backgroundColor;
  final Color? Function(AutocompleteData tag)? textColorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Material(
      color: backgroundColor ?? context.theme.scaffoldBackgroundColor,
      elevation: 4,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            final tag = _tags[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                hoverColor: context.theme.cardColor,
                onTap: () => onItemTap(_tags[index]),
                trailing: tag.hasCount
                    ? Text(
                        NumberFormat.compact().format(tag.postCount),
                        style: const TextStyle(color: Colors.grey),
                      )
                    : null,
                title: _getTitle(
                  tag,
                  theme,
                  currentQuery,
                  textColorBuilder?.call(tag),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _getTitle(
  AutocompleteData tag,
  ThemeMode theme,
  String currentQuery,
  Color? color,
) {
  return tag.hasAlias
      ? Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: color,
            ),
            'body': Style(padding: EdgeInsets.zero, margin: EdgeInsets.zero),
            'b': Style(
              fontWeight: FontWeight.w900,
            ),
          },
          data:
              '<p>${tag.antecedent!.replaceAll('_', ' ').replaceAll(currentQuery, '<b>$currentQuery</b>')} ➞ ${tag.label.replaceAll(currentQuery, '<b>$currentQuery</b>')}</p>',
        )
      : Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: color,
            ),
            'body': Style(padding: EdgeInsets.zero, margin: EdgeInsets.zero),
            'b': Style(
              fontWeight: FontWeight.w900,
            ),
          },
          data:
              '<p>${tag.label.replaceAll(currentQuery, '<b>$currentQuery</b>')}</p>',
        );
}
