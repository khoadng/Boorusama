// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/core/posts/details/details.dart';
import 'package:boorusama/core/theme.dart';
import 'moebooru_comment_item.dart';

class MoebooruCommentSection extends ConsumerWidget {
  const MoebooruCommentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final asyncData = ref.watch(moebooruCommentsProvider(post.id));

    return SliverToBoxAdapter(
      child: asyncData.when(
        data: (comments) => comments.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      thickness: 1.5,
                    ),
                    Text(
                      'comment.comments'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.hintColor,
                            fontSize: 16,
                          ),
                    ),
                    ...comments.map((comment) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: MoebooruCommentItem(comment: comment),
                        ))
                  ],
                ),
              ),
        loading: () => const SizedBox.shrink(),
        error: (e, __) => const SizedBox.shrink(),
      ),
    );
  }
}
