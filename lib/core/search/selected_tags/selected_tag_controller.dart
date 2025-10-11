// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../tags/favorites/favorited.dart';
import '../../tags/metatag/types.dart';
import '../histories/history.dart';
import '../queries/filter_operator.dart';
import 'search_tag_set.dart';
import 'tag_search_item.dart';

class SelectedTagController extends ValueNotifier<List<TagSearchItem>> {
  SelectedTagController({
    required MetatagExtractor? metatagExtractor,
  }) : _tagSet = SearchTagSet(metatagExtractor: metatagExtractor),
       super([]);

  final SearchTagSet _tagSet;

  List<TagSearchItem> get tags => _tagSet.tags;
  List<String> get rawTags => _tagSet.rawTags;
  String get rawTagsString => _tagSet.rawTagsString;
  SearchTagSet get tagSet => _tagSet;

  void addTagFromSearchHistory(SearchHistory history) {
    _tagSet.addTagFromSearchHistory(history);
    value = _tagSet.tags;
  }

  void addTagFromFavTag(FavoriteTag tag) {
    _tagSet.addTagFromFavTag(tag);
    value = _tagSet.tags;
  }

  void merge(
    SearchTagSet tags, {
    bool isRaw = false,
  }) {
    _tagSet.merge(tags, isRaw: isRaw);
    value = _tagSet.tags;
  }

  void addTag(
    String tag, {
    bool isRaw = false,
    FilterOperator operator = FilterOperator.none,
  }) {
    _tagSet.addTag(tag, isRaw: isRaw, operator: operator);
    value = _tagSet.tags;
  }

  void negateTag(String tag) {
    _tagSet.negateTag(tag);
    value = _tagSet.tags;
  }

  void addTags(
    List<String> tags, {
    FilterOperator operator = FilterOperator.none,
  }) {
    _tagSet.addTags(tags, operator: operator);
    value = _tagSet.tags;
  }

  void removeTag(TagSearchItem tag) {
    _tagSet.removeTag(tag);
    value = _tagSet.tags;
  }

  void updateTag(TagSearchItem oldTag, String newTag) {
    _tagSet.updateTag(oldTag, newTag);
    value = _tagSet.tags;
  }

  void clear() {
    _tagSet.clear();
    value = _tagSet.tags;
  }
}
