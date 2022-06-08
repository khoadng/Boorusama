// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'widgets/comment_item.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final int postId;

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Comment> _comments = <Comment>[];
  List<Comment> _commentsWithDeleted = <Comment>[];
  List<Comment> _commentsWithoutDeleted = <Comment>[];
  final bool _showDeleted = false;

  Widget _buildCommentSection(List<Comment> comments) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              title: CommentItem(
                comment: comment,
              ),
            );
          },
          itemCount: comments.length,
        ),
      );
    } else {
      return Center(
        child: Text('commentListing.notifications.noComments'.tr()),
      );
    }
  }

  // void _handleEditTap(BuildContext context, Comment comment, int postId) async {
  //   Navigator.of(context).pop();
  //   await Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) =>
  //           CommentUpdatePage(
  //         postId: widget.postId,
  //         commentId: comment.id,
  //         initialContent: comment.body,
  //       ),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
  //           SharedAxisTransition(
  //         child: child,
  //         animation: animation,
  //         secondaryAnimation: secondaryAnimation,
  //         transitionType: SharedAxisTransitionType.scaled,
  //       ),
  //       transitionDuration: const Duration(milliseconds: 500),
  //     ),
  //   );
  // }

  // void _handleReplyTap(
  //     BuildContext context, Comment comment, int postId) async {
  //   final content =
  //       "[quote]\n${comment.author.displayName} said:\n\n${comment.body}\n[/quote]\n\n";

  //   Navigator.of(context).pop();
  //   await Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) =>
  //           CommentCreatePage(
  //         postId: widget.postId,
  //         initialContent: content,
  //       ),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
  //           SharedAxisTransition(
  //         child: child,
  //         animation: animation,
  //         secondaryAnimation: secondaryAnimation,
  //         transitionType: SharedAxisTransitionType.scaled,
  //       ),
  //       transitionDuration: const Duration(milliseconds: 500),
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    ReadContext(context).read<CommentCubit>().getComment(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: BlocBuilder<CommentCubit,
                          AsyncLoadState<List<Comment>>>(
                        builder: (context, state) {
                          if (state.status == LoadStatus.success) {
                            _commentsWithDeleted = state.data!;
                            _commentsWithoutDeleted = state.data!
                                .where((comment) => comment.isDeleted == false)
                                .toList();

                            WidgetsBinding.instance!
                                .addPostFrameCallback((timeStamp) {
                              setState(() {
                                if (_showDeleted) {
                                  _comments = _commentsWithDeleted;
                                } else {
                                  _comments = _commentsWithoutDeleted;
                                }
                              });
                            });

                            return _buildCommentSection(_comments);
                          } else if (state.status == LoadStatus.failure) {
                            return const Center(
                              child: Text("Something went wrong"),
                            );
                          } else {
                            return Lottie.asset(
                                "assets/animations/comment_loading.json");
                          }
                        },
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
