// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/flutter.dart';
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
        foregroundColor: context.iconTheme.color,
        backgroundColor: context.theme.cardColor,
        side: BorderSide(
          color: context.theme.hintColor,
        ),
      ),
      onPressed: () => goToRelatedTagsPage(context, relatedTag: relatedTag),
      child: const Text('tag.related.more').tr(),
    );
  }
}
