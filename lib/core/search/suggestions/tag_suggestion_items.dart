// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
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
    this.listbox,
    this.onItemPick,
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

  /// Highlights a row picked by keys pressed in the search field.
  final KurumiListboxController? listbox;

  /// Called for a row picked by key, so typing can go on; [onItemTap] when
  /// null.
  final ValueChanged<AutocompleteData>? onItemPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(config));
    final tagSuggestionItemBuilder = booruBuilder?.tagSuggestionItemBuilder;
    final listbox = this.listbox;

    return _tags.isNotEmpty
        ? _registered(
            Material(
              color:
                  backgroundColor ??
                  Kurumi.themeOf(context).colorScheme.surface,
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
                  final item =
                      tagSuggestionItemBuilder?.call(
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

                  return switch (listbox) {
                    final listbox? => ListenableBuilder(
                      listenable: listbox,
                      builder: (context, child) => KurumiListboxItem(
                        active: listbox.active == index,
                        child: child!,
                      ),
                      child: item,
                    ),
                    null => item,
                  };
                },
              ),
            ),
          )
        : emptyBuilder != null
        ? emptyBuilder!()
        : const SizedBox.shrink();
  }

  Widget _registered(Widget list) => switch (listbox) {
    final listbox? => KurumiListbox(
      controller: listbox,
      count: _tags.length,
      reversed: reverse ?? false,
      onPick: (index) => (onItemPick ?? onItemTap)(_tags[index]),
      child: list,
    ),
    null => list,
  };
}
