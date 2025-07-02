// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/details/details.dart';
import '../../../../../core/theme.dart';
import '../../../comments/providers.dart';
import '../../../posts/types.dart';
import 'comment_item.dart';

class MoebooruCommentSection extends ConsumerWidget {
  const MoebooruCommentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final post = InheritedPost.of<MoebooruPost>(context);
    final params = (ref.watchConfigAuth, post.id);

    return SliverToBoxAdapter(
      child: ref.watch(moebooruCommentsProvider(params)).when(
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
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.hintColor,
                            fontSize: 16,
                          ),
                        ),
                        ...comments.map(
                          (comment) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: MoebooruCommentItem(comment: comment),
                          ),
                        ),
                      ],
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (e, __) => const SizedBox.shrink(),
          ),
    );
  }
}
