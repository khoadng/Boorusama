// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../foundation/html.dart';
import '../../boorus/engine/providers.dart';
import '../../configs/config.dart';
import '../../tags/autocompletes/types.dart';
import '../../tags/configs/providers.dart';
import '../../tags/metatag/metatag.dart';
import '../../tags/tag/providers.dart';
import '../../theme.dart';

class TagSuggestionItem extends StatelessWidget {
  const TagSuggestionItem({
    required this.onItemTap,
    required this.tag,
    required this.dense,
    required this.currentQuery,
    required this.textColor,
    required this.showCount,
    required this.metatagExtractor,
    super.key,
  });

  final ValueChanged<AutocompleteData> onItemTap;
  final AutocompleteData tag;
  final bool dense;
  final String currentQuery;
  final Color? textColor;
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
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AppHtml(
      style: {
        'p': Style(
          fontSize: FontSize.medium,
          color: textColor,
          margin: Margins.zero,
        ),
        'b': Style(
          fontWeight: FontWeight.w900,
        ),
      },
      selectable: false,
      data: tag.toDisplayHtml(currentQuery, metatagExtractor),
    );
  }
}

class DefaultTagSuggestionItem extends ConsumerWidget {
  const DefaultTagSuggestionItem({
    required this.config,
    required this.tag,
    required this.onItemTap,
    required this.currentQuery,
    required this.dense,
    super.key,
  });

  final BooruConfigAuth config;
  final AutocompleteData tag;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagInfo = ref.watch(tagInfoProvider);
    final category = tag.category;
    final color = category != null
        ? ref.watch(tagColorProvider((config, category)))
        : null;
    final booruRepo = ref.watch(booruRepoProvider(config));
    final metatagExtractor = booruRepo?.getMetatagExtractor(tagInfo);

    return TagSuggestionItem(
      key: ValueKey(tag.value),
      showCount: tag.hasCount,
      onItemTap: onItemTap,
      tag: tag,
      dense: dense,
      currentQuery: currentQuery,
      textColor: color,
      metatagExtractor: metatagExtractor,
    );
  }
}
