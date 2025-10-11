// Project imports:
import '../../../core/search/queries/query.dart';
import '../../../core/search/search/widgets.dart';
import '../../../core/search/selected_tags/tag.dart';

class EshuushuuSearchController extends SearchPageController {
  EshuushuuSearchController({
    required super.tagsController,
    required this.getCurrentSelectedTagType,
    super.onSearch,
    super.textMatchers,
    super.metatagExtractor,
  });

  final String Function() getCurrentSelectedTagType;

  @override
  void tapTag(String tag) {
    final operatorPrefix = filterOperatorToString(filterOperator);
    tagsController.addTag(
      TagSearchItem.fromString(
        '$operatorPrefix$tag',
        category: getCurrentSelectedTagType(),
      ),
    );

    textController.clear();
  }
}
