// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/comments/comments.dart';
import 'package:boorusama/core/feats/dtext/html_converter.dart';
import 'package:boorusama/core/widgets/comment_header.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

typedef CommentFetcher = Future<List<Comment>> Function(int postId);

class CommentPageScaffold extends ConsumerStatefulWidget {
  const CommentPageScaffold({
    super.key,
    required this.postId,
    required this.fetcher,
    this.commentItemBuilder,
  });

  final int postId;
  final CommentFetcher fetcher;
  final Widget Function(BuildContext, Comment)? commentItemBuilder;

  @override
  ConsumerState<CommentPageScaffold> createState() =>
      _CommentPageScaffoldState();
}

class _CommentPageScaffoldState extends ConsumerState<CommentPageScaffold> {
  List<Comment>? comments;

  @override
  void initState() {
    super.initState();
    widget
        .fetcher(widget.postId)
        .then((value) => setState(() => comments = value));
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return Scaffold(
      appBar: AppBar(
        title: const Text('comment.comments').tr(),
      ),
      body: comments != null
          ? comments!.isNotEmpty
              ? ListView.builder(
                  itemCount: comments!.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: widget.commentItemBuilder != null
                        ? widget.commentItemBuilder!(context, comments![index])
                        : _CommentItem(
                            comment: comments![index],
                            config: config,
                          ),
                  ),
                )
              : const NoDataBox()
          : const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.config,
  });

  final Comment comment;
  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creatorName == null
              ? comment.creatorId?.toString() ?? 'Anon'
              : comment.creatorName!,
          authorTitleColor: context.colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        Html(
          style: {
            'body': Style(
              margin: EdgeInsets.zero,
            ),
          },
          data: dtext(
            comment.body,
            booruUrl: config.url,
          ),
        )
      ],
    );
  }
}
