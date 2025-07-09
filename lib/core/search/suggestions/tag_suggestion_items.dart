// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config.dart';
import '../../tags/autocompletes/types.dart';
import 'tag_suggestion_item.dart';

class TagSuggestionItems extends ConsumerWidget {
  const TagSuggestionItems({
    required IList<AutocompleteData> tags,
    required this.onItemTap,
    required this.currentQuery,
    required this.config,
    super.key,
    this.backgroundColor,
    this.dense = false,
    this.borderRadius,
    this.elevation,
    this.emptyBuilder,
    this.padding,
    this.reverse,
  }) : _tags = tags;

  // This is needed cause this one can be used outside of config scope
  final BooruConfigAuth config;
  final IList<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;
  final String currentQuery;
  final Color? backgroundColor;
  final bool dense;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final Widget Function()? emptyBuilder;
  final EdgeInsetsGeometry? padding;
  final bool? reverse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(config));
    final tagSuggestionItemBuilder = booruBuilder?.tagSuggestionItemBuilder;

    return _tags.isNotEmpty
        ? Material(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            elevation: 0,
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(8)),
            child: ListView.builder(
              reverse: reverse ?? false,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ).copyWith(bottom: 16),
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];

                return tagSuggestionItemBuilder?.call(
                      config,
                      tag,
                      dense,
                      currentQuery,
                      onItemTap,
                    ) ??
                    DefaultTagSuggestionItem(
                      config: config,
                      tag: tag,
                      onItemTap: onItemTap,
                      currentQuery: currentQuery,
                      dense: dense,
                    );
              },
            ),
          )
        : emptyBuilder != null
        ? emptyBuilder!()
        : const SizedBox.shrink();
  }
}
