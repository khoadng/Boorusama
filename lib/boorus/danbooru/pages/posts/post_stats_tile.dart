// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:boorusama/foundation/i18n.dart';

class PostStatsTile extends StatelessWidget {
  const PostStatsTile({
    super.key,
    required this.post,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.totalComments,
  });

  final DanbooruPost post;
  final int totalComments;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        children: [
          _StatButton(
            enable: post.hasFavorite,
            onTap: () => goToPostFavoritesDetails(context, post),
            child: RichText(
              text: TextSpan(
                text: '${post.favCount} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: 'favorites.counter'.plural(post.favCount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StatButton(
            enable: post.hasVoter,
            onTap: () => goToPostVotesDetails(context, post),
            child: RichText(
              text: TextSpan(
                text: '${post.score} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text:
                        '${'post.detail.score'.plural(post.score)} ${_generatePercentText(post)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StatButton(
            enable: post.hasComment,
            child: RichText(
              text: TextSpan(
                text: '$totalComments ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: 'comment.counter'.plural(totalComments),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.child,
    required this.enable,
    this.onTap,
  });

  final Widget child;
  final bool enable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: enable,
      conditionalBuilder: (child) => InkWell(
        onTap: onTap,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}

String _generatePercentText(DanbooruPost post) {
  return post.totalVote > 0
      ? '(${(post.upvotePercent * 100).toInt()}% upvoted)'
      : '';
}
