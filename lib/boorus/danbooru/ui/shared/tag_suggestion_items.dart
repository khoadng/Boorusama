// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/ui/features/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/users/user_level_colors.dart';
import 'package:boorusama/core/application/search_history/search_history_suggestions.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/domain/autocompletes/autocomplete.dart';
import 'package:boorusama/core/ui/widgets/context_menu.dart';

class TagSuggestionItems extends StatelessWidget {
  const TagSuggestionItems({
    super.key,
    required List<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
    this.backgroundColor,
  }) : _tags = tags;

  final List<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final Color? backgroundColor;

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
                    title: _getTitle(tag, state.theme, currentQuery),
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

// ignore: prefer-single-widget-per-file
class SliverTagSuggestionItemsWithHistory extends StatelessWidget {
  const SliverTagSuggestionItemsWithHistory({
    super.key,
    required this.tags,
    required this.histories,
    required this.onItemTap,
    required this.onHistoryTap,
    required this.onHistoryDeleted,
    required this.currentQuery,
  });

  final List<AutocompleteData> tags;
  final List<HistorySuggestion> histories;
  final void Function(AutocompleteData tag) onItemTap;
  final void Function(HistorySuggestion history) onHistoryTap;
  final void Function(HistorySuggestion history) onHistoryDeleted;
  final String currentQuery;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (histories.isNotEmpty)
                ListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  title: Text(
                    'search.history.recent',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                  ).tr(),
                ),
              ...histories.map(
                (history) => ContextMenu<String>(
                  items: const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Remove'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      onHistoryDeleted.call(history);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListTile(
                      hoverColor: Theme.of(context).cardColor,
                      visualDensity: VisualDensity.compact,
                      trailing: const Icon(
                        Icons.history,
                        color: Colors.grey,
                      ),
                      title: Html(
                        style: {
                          'p': Style(
                            fontSize: FontSize.medium,
                          ),
                          'body': Style(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                          ),
                          'b': Style(
                            color: Colors.redAccent,
                          ),
                        },
                        data: '<p>${history.tag.replaceAll(
                              history.term,
                              '<b>${history.term}</b>',
                            ).replaceAll('_', ' ')}</p>',
                      ),
                      onTap: () => onHistoryTap(history),
                    ),
                  ),
                ),
              ),
              if (histories.isNotEmpty) const Divider(thickness: 1),
              ...tags.map(
                (tag) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    hoverColor: Theme.of(context).cardColor,
                    onTap: () => onItemTap(tag),
                    trailing: tag.hasCount
                        ? Text(
                            NumberFormat.compact().format(tag.postCount),
                            style: const TextStyle(color: Colors.grey),
                          )
                        : null,
                    title: BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) => _getTitle(
                        tag,
                        state.theme,
                        currentQuery.replaceAll('_', ' '),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _getTitle(AutocompleteData tag, ThemeMode theme, String currentQuery) {
  return tag.hasAlias
      ? Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: _getTagColor(tag, theme),
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
              color: _getTagColor(tag, theme),
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

Color? _getTagColor(AutocompleteData tag, ThemeMode theme) {
  if (tag.hasCategory) {
    return getTagColor(
      stringToTagCategory(tag.category!),
      theme,
    );
  } else if (tag.hasUserLevel) {
    return Color(getUserHexColor(stringToUserLevel(tag.level!)));
  }

  return null;
}
