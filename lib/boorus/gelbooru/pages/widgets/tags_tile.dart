// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/tags/post_tag_list.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class TagsTile extends StatelessWidget {
  const TagsTile({
    super.key,
    required this.post,
    this.onExpand,
    this.onTagTap,
    this.initialExpanded = false,
    required this.tags,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function(Tag tag)? onTagTap;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initialExpanded,
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) => value ? onExpand?.call() : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              tags: tags,
              onTap: onTagTap,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
