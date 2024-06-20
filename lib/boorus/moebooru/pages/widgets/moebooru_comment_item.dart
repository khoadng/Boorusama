// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/comments/comments.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/dtext/html_converter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class MoebooruCommentItem extends ConsumerWidget {
  const MoebooruCommentItem({
    super.key,
    required this.comment,
  });

  final MoebooruComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creator,
          authorTitleColor: context.colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        Html(
          style: {
            'body': Style(
              margin: Margins.zero,
            ),
          },
          data: dtext(
            comment.body,
            booruUrl: booruConfig.url,
          ),
        )
      ],
    );
  }
}
