// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../router.dart';
import 'danbooru_related_tag.dart';
import 'related_tag_action_sheet.dart';

void goToRelatedTagsPage(
  BuildContext context, {
  required DanbooruRelatedTag relatedTag,
  required void Function(DanbooruRelatedTagItem tag) onAdded,
  required void Function(DanbooruRelatedTagItem tag) onNegated,
}) {
  showAdaptiveSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.relatedTags,
    ),
    builder: (context) => RelatedTagActionSheet(
      relatedTag: relatedTag,
      onAdded: onAdded,
      onNegated: onNegated,
    ),
  );
}
