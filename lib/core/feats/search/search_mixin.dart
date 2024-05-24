// Project imports:
import 'filter_operator.dart';
import 'search_utils.dart';
import 'selected_tag_controller.dart';

typedef HistoryAdder = void Function(String tag);
typedef QueryClearer = void Function();
typedef QueryUpdater = void Function(String query);
typedef QueryGetter = String Function();

mixin SearchMixin {
  void submit(String value) {
    selectedTagController.addTag(value);
  }

  void skipToResultWithTag(String tag) {
    selectedTagController.clear();
    selectedTagController.addTag(tag);
    addHistory(selectedTagController.rawTags.join(' '));
  }

  void search() {
    addHistory(selectedTagController.rawTags.join(' '));
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );

    clearQuery();
  }

  void tapHistoryTag(String tag) {
    selectedTagController.addTags(tag.split(' '));
  }

  void tapRawMetaTag(String tag) => updateQuery('$tag:');

  HistoryAdder get addHistory;
  QueryClearer get clearQuery;
  QueryUpdater get updateQuery;
  QueryGetter get getQuery;
  SelectedTagController get selectedTagController;
  FilterOperator get filterOperator => getFilterOperator(getQuery());
}
