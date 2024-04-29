// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/core/feats/autocompletes/autocomplete.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';

class TagSuggestionItems extends ConsumerWidget {
  const TagSuggestionItems({
    super.key,
    required IList<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
    this.backgroundColor,
    this.textColorBuilder,
    this.dense = false,
  }) : _tags = tags;

  final IList<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final Color? backgroundColor;
  final Color? Function(AutocompleteData tag)? textColorBuilder;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: backgroundColor ?? context.theme.scaffoldBackgroundColor,
      elevation: 4,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: ListView.builder(
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            final tag = _tags[index];

            return InkWell(
              onTap: tag.forceChooseSubOption && tag.hasSubOptions
                  ? null
                  : () => onItemTap(tag),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: dense ? 4 : 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _getTitle(
                        tag,
                        currentQuery,
                        textColorBuilder?.call(tag),
                      ),
                    ),
                    tag.hasSubOptions
                        ? Wrap(
                            spacing: 4,
                            children: tag.subOptions!
                                .map(
                                  (e) => ActionChip(
                                    visualDensity: VisualDensity.compact,
                                    side: BorderSide(
                                      color: context.theme.hintColor
                                          .withOpacity(0.2),
                                    ),
                                    onPressed: () => onItemTap(
                                      tag.overrideWithSubOptions(e),
                                    ),
                                    label: Text(
                                      e.value,
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : const SizedBox(),
                    if (tag.hasCount && !ref.watchConfig.hasStrictSFW)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          NumberFormat.compact().format(tag.postCount),
                          style: TextStyle(
                            color: context.theme.hintColor,
                          ),
                        ),
                      ),
                  ],
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
  String currentQuery,
  Color? color,
) {
  final query = currentQuery.replaceUnderscoreWithSpace().toLowerCase();
  return tag.hasAlias
      ? Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: color,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            ),
            'body': Style(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            ),
            'b': Style(
              fontWeight: FontWeight.w900,
            ),
          },
          data:
              '<p>${tag.antecedent!.replaceUnderscoreWithSpace().replaceAll(query, '<b>$query</b>')} ➞ ${tag.label.replaceAll(query, '<b>$query</b>')}</p>',
        )
      : Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: color,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            ),
            'body': Style(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            ),
            'b': Style(
              fontWeight: FontWeight.w900,
            ),
          },
          data:
              '<p>${tag.label.replaceAll(query.replaceUnderscoreWithSpace(), '<b>$query</b>')}</p>',
        );
}
