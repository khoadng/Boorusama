// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/widgets/tags/post_tag_list.dart';
import 'package:boorusama/flutter.dart';

class TagsTile extends ConsumerWidget {
  const TagsTile({
    super.key,
    required this.post,
    this.onExpand,
    this.onTagTap,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function(Tag tag)? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) => value ? onExpand?.call() : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              tags: ref.watch(tagsProvider),
              onTap: onTagTap,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
