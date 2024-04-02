// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/comments/comments.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'moebooru_comment_item.dart';

class MoebooruCommentSection extends ConsumerWidget {
  const MoebooruCommentSection({
    super.key,
    required this.post,
    this.allowFetch = true,
  });

  final Post post;
  final bool allowFetch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!allowFetch) {
      return const SizedBox.shrink();
    }

    final asyncData = ref.watch(moebooruCommentsProvider(post.id));

    return asyncData.when(
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
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.theme.hintColor,
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
    );
  }
}
