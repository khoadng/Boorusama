// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/search/histories/history.dart';
import '../../../core/search/queries/query.dart';
import '../../../core/search/search/widgets.dart';
import '../../../core/search/selected_tags/tag.dart';
import '../../../core/tags/favorites/favorited.dart';
import 'routes.dart';

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

  Future<void> tapFavTagWithDialog(
    BuildContext context,
    FavoriteTag tag,
  ) async {
    // If it's a list query, parse and ask for each tag
    if (tag.queryType == QueryType.list) {
      final tags = tag.queryAsList();
      for (final tagName in tags) {
        final selectedType = await showTagTypeSelectionSheet(
          context,
          tagName: tagName,
        );

        if (selectedType != null) {
          final operatorPrefix = filterOperatorToString(filterOperator);
          tagsController.addTag(
            TagSearchItem.fromString(
              '$operatorPrefix$tagName',
              category: selectedType.valueStr,
            ),
          );
        } else {
          // User cancelled, stop processing remaining tags
          break;
        }
      }
      textController.clear();
      return;
    }

    // For single tags (including simple/raw), show dialog to select category
    final selectedType = await showTagTypeSelectionSheet(
      context,
      tagName: tag.query,
    );

    if (selectedType != null) {
      final operatorPrefix = filterOperatorToString(filterOperator);
      tagsController.addTag(
        TagSearchItem.fromString(
          '$operatorPrefix${tag.query}',
          category: selectedType.valueStr,
        ),
      );

      textController.clear();
    }
  }

  Future<void> tapHistoryTagWithDialog(
    BuildContext context,
    SearchHistory history,
  ) async {
    // If it's a list query, parse and ask for each tag
    if (history.queryType == QueryType.list) {
      final tags = history.queryAsList();
      for (final tagName in tags) {
        final selectedType = await showTagTypeSelectionSheet(
          context,
          tagName: tagName,
        );

        if (selectedType != null) {
          final operatorPrefix = filterOperatorToString(filterOperator);
          tagsController.addTag(
            TagSearchItem.fromString(
              '$operatorPrefix$tagName',
              category: selectedType.valueStr,
            ),
          );
        } else {
          // User cancelled, stop processing remaining tags
          break;
        }
      }
      textController.clear();
      return;
    }

    // For single tags (including simple/raw), show dialog to select category
    final selectedType = await showTagTypeSelectionSheet(
      context,
      tagName: history.query,
    );

    if (selectedType != null) {
      final operatorPrefix = filterOperatorToString(filterOperator);
      tagsController.addTag(
        TagSearchItem.fromString(
          '$operatorPrefix${history.query}',
          category: selectedType.valueStr,
        ),
      );

      textController.clear();
    }
  }
}
