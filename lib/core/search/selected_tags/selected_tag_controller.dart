// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../tags/favorites/favorited.dart';
import '../../tags/metatag/types.dart';
import '../histories/history.dart';
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

  void addTag(TagSearchItem tag) {
    _tagSet.addTag(tag);
    value = _tagSet.tags;
  }

  void addTags(List<TagSearchItem> tags) {
    _tagSet.addTags(tags);
    value = _tagSet.tags;
  }

  void removeTag(TagSearchItem tag) {
    _tagSet.removeTag(tag);
    value = _tagSet.tags;
  }

  void updateTag(TagSearchItem oldTag, TagSearchItem newTag) {
    _tagSet.updateTag(oldTag, newTag);
    value = _tagSet.tags;
  }

  void clear() {
    _tagSet.clear();
    value = _tagSet.tags;
  }
}
