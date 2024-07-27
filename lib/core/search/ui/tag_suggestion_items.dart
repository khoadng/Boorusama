// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/metatag.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';

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
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final tag = _tags[index];

          return TagSuggestionItem(
            key: ValueKey(tag.value),
            showCount: tag.hasCount && !ref.watchConfig.hasStrictSFW,
            onItemTap: onItemTap,
            tag: tag,
            dense: dense,
            currentQuery: currentQuery,
            textColorBuilder: textColorBuilder,
            metatagExtractor:
                ref.watchBooruBuilder(ref.watchConfig)?.metatagExtractor,
          );
        },
      ),
    );
  }
}

class TagSuggestionItem extends StatelessWidget {
  const TagSuggestionItem({
    super.key,
    required this.onItemTap,
    required this.tag,
    required this.dense,
    required this.currentQuery,
    required this.textColorBuilder,
    required this.showCount,
    required this.metatagExtractor,
  });

  final ValueChanged<AutocompleteData> onItemTap;
  final AutocompleteData tag;
  final bool dense;
  final String currentQuery;
  final Color? Function(AutocompleteData tag)? textColorBuilder;
  final bool showCount;
  final MetatagExtractor? metatagExtractor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () => onItemTap(tag),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: dense ? 4 : 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTitle(),
            ),
            if (showCount)
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
  }

  Widget _buildTitle() {
    final color = textColorBuilder != null ? textColorBuilder!(tag) : null;

    return Html(
      style: {
        'p': Style(
          fontSize: FontSize.medium,
          color: color,
          margin: Margins.zero,
        ),
        'body': Style(
          margin: Margins.zero,
        ),
        'b': Style(
          fontWeight: FontWeight.w900,
        ),
      },
      data: tag.toDisplayHtml(currentQuery, metatagExtractor),
    );
  }
}
