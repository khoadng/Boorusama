// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/comments/widgets.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/dtext/dtext.dart';
import '../../../../../foundation/html.dart';
import '../../../comments/types.dart';

class MoebooruCommentItem extends ConsumerWidget {
  const MoebooruCommentItem({
    required this.comment,
    super.key,
  });

  final MoebooruComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creator,
          authorTitleColor: Theme.of(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        AppHtml(
          data: dtext(
            comment.body,
            booruUrl: booruConfig.url,
          ),
        ),
      ],
    );
  }
}
