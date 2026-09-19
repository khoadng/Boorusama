// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../dtext/widgets.dart';
import '../types/comment.dart';
import 'comment_header.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    required this.comment,
    required this.config,
    this.footerBuilder,
    super.key,
  });

  final Comment comment;
  final BooruConfigAuth config;
  final Widget Function(BuildContext context)? footerBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName:
              comment.creatorName ?? comment.creatorId?.toString() ?? 'Anon',
          authorTitleColor: Kurumi.themeOf(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        DTextBody(
          data: comment.body,
          booruUrl: config.url,
        ),
        if (footerBuilder case final buildFooter?) buildFooter(context),
      ],
    );
  }
}
