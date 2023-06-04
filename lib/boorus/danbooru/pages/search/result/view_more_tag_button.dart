// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class ViewMoreTagButton extends StatelessWidget {
  const ViewMoreTagButton({
    super.key,
    required this.relatedTag,
  });

  final RelatedTag relatedTag;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).iconTheme.color,
        backgroundColor: Theme.of(context).cardColor,
        side: BorderSide(
          color: Theme.of(context).hintColor,
        ),
      ),
      onPressed: () => goToRelatedTagsPage(context, relatedTag: relatedTag),
      child: const Text('tag.related.more').tr(),
    );
  }
}
