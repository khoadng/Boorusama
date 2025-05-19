// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../../../core/boorus/engine/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/search/suggestions/widgets.dart';
import '../../../core/tags/configs/providers.dart';
import '../../../core/tags/tag/providers.dart';
import '../users/user/providers.dart';

class DanbooruTagSuggestionItem extends ConsumerWidget {
  const DanbooruTagSuggestionItem({
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
    final booruBuilder = ref.watch(booruBuilderProvider(config));
    final metatagExtractorBuilder = booruBuilder?.metatagExtractorBuilder;

    return TagSuggestionItem(
      key: ValueKey(tag.value),
      showCount: tag.hasCount && !ref.watchConfigAuth.hasStrictSFW,
      onItemTap: onItemTap,
      tag: tag,
      dense: dense,
      currentQuery: currentQuery,
      textColor: generateAutocompleteTagColor(
        ref,
        ref.context,
        tag,
      ),
      metatagExtractor: metatagExtractorBuilder?.call(tagInfo),
    );
  }
}

Color? generateAutocompleteTagColor(
  WidgetRef ref,
  BuildContext context,
  AutocompleteData tag,
) {
  if (tag.hasCategory) {
    return ref.watch(tagColorProvider(tag.category!));
  } else if (tag.hasUserLevel) {
    return DanbooruUserColor.of(context).fromString(tag.level);
  }

  return null;
}
