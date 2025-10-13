// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/types.dart';
import '../../../tags/categories/providers.dart';
import '../../../tags/tag/colors.dart';
import '../../../themes/colors/providers.dart';
import 'local_providers.dart';

class TagSuggestionsNotifier
    extends AutoDisposeAsyncNotifier<TagSuggestionsState> {
  @override
  Future<TagSuggestionsState> build() async {
    return const TagSuggestionsState.initial();
  }

  Future<void> loadSuggestions(BooruConfigAuth config, String tagString) async {
    var currentState = await future;

    if (tagString == currentState.lastSearchText) return;

    if (tagString.isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(
          suggestions: const [],
          lastSearchText: tagString,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        lastSearchText: tagString,
      ),
    );

    try {
      final tags = tagString.trim().split(' ');
      final tag = tags.lastOrNull?.trim();

      if (tag == null || tag.isEmpty) {
        state = AsyncValue.data(
          currentState.copyWith(
            suggestions: const [],
          ),
        );
        return;
      }

      final sortedTags = await ref.watch(sortedTagsProvider.future);

      final filteredTags = sortedTags
          .where((entry) => entry.key.contains(tag))
          .take(5)
          .toList();

      final tagTypeStore = await ref.watch(booruTagTypeStoreProvider.future);
      final colorScheme = ref.watch(colorSchemeProvider);
      final tagColorGenerator = ref
          .watch(booruRepoProvider(config))
          ?.tagColorGenerator();

      final result = <TagWithColor>[];

      for (final entry in filteredTags) {
        Color? color;
        if (tagColorGenerator != null) {
          final tagType = await tagTypeStore.getTagCategory(
            config.url,
            entry.key,
          );
          color = tagColorGenerator.generateColor(
            TagColorOptions(
              tagType: tagType,
              colors: TagColors.fromBrightness(colorScheme.brightness),
            ),
          );
        }

        result.add(
          TagWithColor(
            tag: entry.key,
            count: entry.value,
            color: color,
          ),
        );
      }

      currentState = await future;

      state = AsyncValue.data(
        currentState.copyWith(
          suggestions: result,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final sortedTagsProvider =
    FutureProvider.autoDispose<List<MapEntry<String, int>>>((
      ref,
    ) async {
      final tagMap = await ref.watch(tagMapProvider.future);
      return tagMap.entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .toList();
    });

final tagSuggestionsProvider =
    AutoDisposeAsyncNotifierProvider<
      TagSuggestionsNotifier,
      TagSuggestionsState
    >(
      TagSuggestionsNotifier.new,
      dependencies: [colorSchemeProvider],
    );

class TagSuggestionsState extends Equatable {
  const TagSuggestionsState({
    required this.suggestions,
    required this.lastSearchText,
  });

  const TagSuggestionsState.initial()
    : suggestions = const [],
      lastSearchText = '';

  final List<TagWithColor> suggestions;
  final String lastSearchText;

  TagSuggestionsState copyWith({
    List<TagWithColor>? suggestions,
    String? lastSearchText,
  }) => TagSuggestionsState(
    suggestions: suggestions ?? this.suggestions,
    lastSearchText: lastSearchText ?? this.lastSearchText,
  );

  @override
  List<Object> get props => [suggestions, lastSearchText];
}

class TagWithColor extends Equatable {
  const TagWithColor({
    required this.tag,
    required this.count,
    this.color,
  });

  final String tag;
  final int count;
  final Color? color;

  @override
  List<Object?> get props => [tag, count, color];

  @override
  String toString() => tag;
}
