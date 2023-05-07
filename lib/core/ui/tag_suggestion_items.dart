// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/autocompletes/autocomplete.dart';

class TagSuggestionItems extends StatelessWidget {
  const TagSuggestionItems({
    super.key,
    required List<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
    this.backgroundColor,
    this.textColorBuilder,
  }) : _tags = tags;

  final List<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final Color? backgroundColor;
  final Color? Function(AutocompleteData tag)? textColorBuilder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    hoverColor: Theme.of(context).cardColor,
                    onTap: () => onItemTap(_tags[index]),
                    trailing: tag.hasCount
                        ? Text(
                            NumberFormat.compact().format(tag.postCount),
                            style: const TextStyle(color: Colors.grey),
                          )
                        : null,
                    title: _getTitle(
                      tag,
                      state.theme,
                      currentQuery,
                      textColorBuilder?.call(tag),
                    ),
                  ),
                );
              },
            ),
          );
        },
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
