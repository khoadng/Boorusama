// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/tags/tag_info_service.dart';
import 'package:boorusama/boorus/core/provider.dart';

final selectedTagsProvider =
    NotifierProvider.autoDispose<SelectedTagsNotifier, List<TagSearchItem>>(
        () => throw UnimplementedError(),
        dependencies: [
      tagInfoProvider,
    ]);

final selectedRawTagStringProvider = Provider.autoDispose<List<String>>((ref) {
  final selectedTags = ref.watch(selectedTagsProvider);
  return selectedTags.map((tag) => tag.toString()).toList();
}, dependencies: [
  selectedTagsProvider,
]);

class SelectedTagsNotifier extends AutoDisposeNotifier<List<TagSearchItem>> {
  SelectedTagsNotifier() : super();

  @override
  List<TagSearchItem> build() {
    return [];
  }

  TagSearchItem _toItem(String tag) => TagSearchItem.fromString(tag, tagInfo);
  String _applyOperator(String tag, FilterOperator operator) =>
      '${filterOperatorToString(operator)}$tag';

  void addTag(
    String tag, {
    FilterOperator operator = FilterOperator.none,
  }) {
    final updatedTags = Set<TagSearchItem>.from(state)
      ..add(_toItem(_applyOperator(tag, operator)));
    state = updatedTags.toList();
  }

  void addTags(
    List<String> tags, {
    FilterOperator operator = FilterOperator.none,
  }) {
    final updatedTags = Set<TagSearchItem>.from(state)
      ..addAll(tags.map((tag) => _applyOperator(tag, operator)).map(_toItem));
    state = updatedTags.toList();
  }

  void removeTag(TagSearchItem tag) {
    final updatedTags = List<TagSearchItem>.from(state)..remove(tag);
    state = updatedTags;
  }

  void clear() {
    state = [];
  }

  TagInfo get tagInfo => ref.read(tagInfoProvider);
}
