// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/search/selected_tags/types.dart';
import '../tags/parser.dart';
import 'types.dart';

class EshuushuuInheritedTagsTile extends ConsumerWidget {
  const EshuushuuInheritedTagsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultInheritedTagsTile<EshuushuuPost>(
      onTagTap: (tag) {
        final tagSet = SearchTagSet();
        tagSet.addTag(
          TagSearchItem.fromString(
            tag.name,
            category: parseTagCategoryToEshuushuuTagType(tag.category).valueStr,
          ),
        );

        goToSearchPage(
          ref,
          tags: tagSet,
        );
      },
    );
  }
}
