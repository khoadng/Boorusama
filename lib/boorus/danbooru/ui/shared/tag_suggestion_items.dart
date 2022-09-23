// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search_history/search_history_suggestions.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class TagSuggestionItems extends StatelessWidget {
  const TagSuggestionItems({
    Key? key,
    required List<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
  })  : _tags = tags,
        super(key: key);

  final List<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              final tag = _tags[index];
              return ListTile(
                onTap: () => onItemTap(_tags[index]),
                trailing: tag.hasCount
                    ? Text(NumberFormat.compact().format(tag.postCount),
                        style: const TextStyle(color: Colors.grey))
                    : null,
                title: _getTitle(tag, state.theme, currentQuery),
              );
            },
          );
        },
      ),
    );
  }
}

class SliverTagSuggestionItemsWithHistory extends StatelessWidget {
  const SliverTagSuggestionItemsWithHistory({
    Key? key,
    required this.tags,
    required this.histories,
    required this.onItemTap,
    required this.onHistoryTap,
    required this.onMetatagTap,
    required this.currentQuery,
    required this.metatags,
  }) : super(key: key);

  final List<AutocompleteData> tags;
  final List<HistorySuggestion> histories;
  final void Function(AutocompleteData tag) onItemTap;
  final void Function(HistorySuggestion history) onHistoryTap;
  final void Function(Metatag tag) onMetatagTap;
  final String currentQuery;
  final List<Metatag> metatags;

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
                    'Recent',
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                  ),
                ),
              ...histories.map(
                (history) => ListTile(
                  visualDensity: VisualDensity.compact,
                  trailing: const Icon(
                    Icons.history,
                    color: Colors.grey,
                  ),
                  title: Html(
                    style: {
                      'p': Style(
                        fontSize: const FontSize(16),
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
              if (histories.isNotEmpty) const Divider(),
              if (metatags.isNotEmpty)
                ListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Metatags',
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                      ),
                      IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => showGeneralDialog(
                              context: context,
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  AlertDialog(
                                    title: const Text('Metatags'),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    content: const Text(
                                        'Free metatags do not count against the tag search limits.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      )
                                    ],
                                  )),
                          icon: const Icon(Icons.info_rounded))
                    ],
                  ),
                ),
              ...metatags.map(
                (tag) => ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(tag.name),
                  trailing: tag.isFree
                      ? const Chip(
                          label: Text('Free'),
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                  onTap: () => onMetatagTap(tag),
                ),
              ),
              if (metatags.isNotEmpty) const Divider(),
              ...tags
                  .map(
                    (tag) => ListTile(
                      onTap: () => onItemTap(tag),
                      trailing: tag.hasCount
                          ? Text(NumberFormat.compact().format(tag.postCount),
                              style: const TextStyle(color: Colors.grey))
                          : null,
                      title: BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, state) => _getTitle(tag, state.theme,
                            currentQuery.replaceAll('_', ' ')),
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        )
      ],
    );
  }
}

Widget _getTitle(AutocompleteData tag, ThemeMode theme, String currentQuery) {
  if (tag.hasAlias) {
    return Html(
      style: {
        'p': Style(
          fontSize: const FontSize(16),
          color: _getTagColor(tag, theme),
        ),
        'body': Style(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
        ),
        'b': Style(
          fontWeight: FontWeight.w900,
        ),
      },
      data: '<p>${tag.antecedent!.replaceAll('_', ' ').replaceAll(
            currentQuery,
            '<b>$currentQuery</b>',
          )} ➞ ${tag.label.replaceAll(
        currentQuery,
        '<b>$currentQuery</b>',
      )}</p>',
    );
  } else {
    return Html(
      style: {
        'p': Style(
          fontSize: const FontSize(16),
          color: _getTagColor(tag, theme),
        ),
        'body': Style(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
        ),
        'b': Style(
          fontWeight: FontWeight.w900,
        ),
      },
      data: '<p>${tag.label.replaceAll(
        currentQuery,
        '<b>$currentQuery</b>',
      )}</p>',
    );
  }
}

Color? _getTagColor(AutocompleteData tag, ThemeMode theme) {
  if (tag.hasCategory) {
    return getTagColor(
      intToTagCategory(tag.category!.getIndex()),
      theme,
    );
  } else if (tag.hasUserLevel) {
    return Color(tag.level!.hexColor);
  }

  return null;
}
