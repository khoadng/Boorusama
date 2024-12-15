// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../autocompletes/autocompletes.dart';
import '../../boorus/engine/providers.dart';
import '../../configs/ref.dart';
import '../../foundation/html.dart';
import '../../tags/configs/providers.dart';
import '../../tags/metatag/metatag.dart';
import '../../theme.dart';

class TagSuggestionItems extends ConsumerWidget {
  const TagSuggestionItems({
    super.key,
    required IList<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
    this.backgroundColor,
    this.textColorBuilder,
    this.dense = false,
    this.borderRadius,
    this.elevation,
  }) : _tags = tags;

  final IList<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final Color? backgroundColor;
  final Color? Function(AutocompleteData tag)? textColorBuilder;
  final bool dense;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagInfo = ref.watch(tagInfoProvider);

    return Material(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: elevation ?? 4,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
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
            showCount: tag.hasCount && !ref.watchConfigAuth.hasStrictSFW,
            onItemTap: onItemTap,
            tag: tag,
            dense: dense,
            currentQuery: currentQuery,
            textColorBuilder: textColorBuilder,
            metatagExtractor: ref
                .watch(currentBooruBuilderProvider)
                ?.metatagExtractorBuilder
                ?.call(tagInfo),
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
    final color = textColorBuilder != null ? textColorBuilder!(tag) : null;

    return AppHtml(
      style: {
        'p': Style(
          fontSize: FontSize.medium,
          color: color,
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
