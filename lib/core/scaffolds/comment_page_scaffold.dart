// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../foundation/html.dart';
import '../comments/comment.dart';
import '../comments/comment_header.dart';
import '../configs/config.dart';
import '../configs/ref.dart';
import '../dtext/dtext.dart';
import '../widgets/widgets.dart';

typedef CommentFetcher = Future<List<Comment>> Function(int postId);

class CommentPageScaffold extends ConsumerStatefulWidget {
  const CommentPageScaffold({
    super.key,
    required this.postId,
    required this.fetcher,
    this.commentItemBuilder,
    required this.useAppBar,
  });

  final int postId;
  final CommentFetcher fetcher;
  final Widget Function(BuildContext context, Comment comment)?
      commentItemBuilder;
  final bool useAppBar;

  @override
  ConsumerState<CommentPageScaffold> createState() =>
      _CommentPageScaffoldState();
}

class _CommentPageScaffoldState extends ConsumerState<CommentPageScaffold> {
  List<Comment>? comments;

  @override
  void initState() {
    super.initState();
    widget.fetcher(widget.postId).then((value) {
      if (mounted) {
        setState(() => comments = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    return Scaffold(
      appBar: widget.useAppBar
          ? AppBar(
              title: const Text('comment.comments').tr(),
            )
          : null,
      body: comments != null
          ? comments!.isNotEmpty
              ? Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 12),
                  child: ListView.builder(
                    itemCount: comments!.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: widget.commentItemBuilder != null
                          ? widget.commentItemBuilder!(
                              context,
                              comments![index],
                            )
                          : _CommentItem(
                              comment: comments![index],
                              config: config,
                            ),
                    ),
                  ),
                )
              : const NoDataBox()
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.config,
  });

  final Comment comment;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creatorName == null
              ? comment.creatorId?.toString() ?? 'Anon'
              : comment.creatorName!,
          authorTitleColor: Theme.of(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        AppHtml(
          data: dtext(
            comment.body,
            booruUrl: config.url,
          ),
        ),
      ],
    );
  }
}
