// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'related_tags.dart';

class RelatedTagSection extends ConsumerWidget {
  const RelatedTagSection({
    super.key,
    required this.query,
    required this.onAdded,
    required this.onNegated,
    this.backgroundColor,
  });

  final String query;
  final void Function(DanbooruRelatedTagItem tag) onAdded;
  final void Function(DanbooruRelatedTagItem tag) onNegated;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) return const SizedBox();

    return ref.watch(danbooruRelatedTagProvider(query)).when(
          data: (tag) => tag.tags.isNotEmpty
              ? RelatedTagHeader(
                  backgroundColor: backgroundColor,
                  relatedTag: tag,
                  onAdded: onAdded,
                  onNegated: onNegated,
                )
              : const SizedBox.shrink(),
          loading: () => TagChipsPlaceholder(
            backgroundColor: backgroundColor,
            height: 44,
          ),
          error: (e, s) => const SizedBox.shrink(),
        );
  }
}
