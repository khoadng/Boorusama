// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/posts/posts.dart';
import 'package:boorusama/boorus/core/tags/tags.dart';
import 'package:boorusama/boorus/core/ui/tags/post_tag_list.dart';

class TagsTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) => value ? onExpand?.call() : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              onTap: onTagTap,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
