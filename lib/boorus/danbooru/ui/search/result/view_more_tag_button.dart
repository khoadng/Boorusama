// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

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
