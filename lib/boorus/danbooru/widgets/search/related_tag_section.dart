// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/tags/tag_chips_placeholder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'related_tag_header.dart';

class RelatedTagSection extends ConsumerWidget {
  const RelatedTagSection({
    super.key,
    required this.query,
    required this.onSelected,
    this.backgroundColor,
  });

  final String query;
  final void Function(RelatedTagItem tag) onSelected;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(danbooruRelatedTagProvider(query));

    return tag == null
        ? TagChipsPlaceholder(
            backgroundColor: backgroundColor,
          )
        : tag.tags.isEmpty
            ? const SizedBox()
            : RelatedTagHeader(
                backgroundColor: backgroundColor,
                relatedTag: tag,
                onSelected: onSelected,
              );
  }
}
