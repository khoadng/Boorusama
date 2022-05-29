// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'comment_create_page.dart';
import 'comment_update_page.dart';
import 'widgets/comment_item.dart';

final _commentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final commentRepo = ref.watch(commentProvider);
  final userRepo = ref.watch(userProvider);
  final dtos = await commentRepo.getCommentsFromPostId(postId);
  final comments = dtos.where((e) => e.creatorId != null).toList().toList();

  final userList = comments.map((e) => e.creatorId).toSet().toList();
  final users = await userRepo.getUsersByIdStringComma(userList.join(","));

  final commentsWithAuthor =
      (comments..sort((a, b) => a.id.compareTo(b.id))).map((comment) {
    final author = users.where((user) => user.id == comment.creatorId).first;
    return comment.copyWith(author: author);
  }).toList();

  /// Cache the artist posts once it was successfully obtained.
  ref.maintainState = true;

  return commentsWithAuthor;
});

class CommentPage extends StatefulWidget {
  const CommentPage({
    Key key,
    @required this.postId,
  }) : super(key: key);

  final int postId;

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Comment> _comments = <Comment>[];
  List<Comment> _commentsWithDeleted = <Comment>[];
  List<Comment> _commentsWithoutDeleted = <Comment>[];
  // List<User> _users = <User>[];
  bool _showDeleted = false;

  Widget _buildCommentSection(List<Comment> comments) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Consumer(
              builder: (_, watch, __) {
                final isLoggedIn = watch(isLoggedInProvider);

                return ListTile(
                  //TODO: comment feature is not ready yet
                  // onLongPress: () => isLoggedIn
                  //     ? showMaterialModalBottomSheet(
                  //         context: context,
                  //         builder: (context) => Material(
                  //           child: SafeArea(
                  //             top: false,
                  //             child: Column(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: <Widget>[
                  //                 ListTile(
                  //                   title: Text(I18n.of(context)
                  //                       .commentListingCommandsEdit),
                  //                   leading: Icon(Icons.edit),
                  //                   onTap: () => _handleEditTap(
                  //                       context, comment, widget.postId),
                  //                 ),
                  //                 ListTile(
                  //                   title: Text(I18n.of(context)
                  //                       .commentListingCommandsReply),
                  //                   leading: Icon(Icons.folder_open),
                  //                   onTap: () => _handleReplyTap(
                  //                       context, comment, widget.postId),
                  //                 ),
                  //                 ListTile(
                  //                   title: Text(I18n.of(context)
                  //                       .commentListingCommandsDelete),
                  //                   leading: Icon(Icons.delete),
                  //                   onTap: () => Navigator.of(context).pop(),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : null,
                  title: CommentItem(
                    comment: comment,
                  ),
                );
              },
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

  void _handleEditTap(BuildContext context, Comment comment, int postId) async {
    Navigator.of(context).pop();
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CommentUpdatePage(
          postId: widget.postId,
          commentId: comment.id,
          initialContent: comment.body,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
        ),
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  void _handleReplyTap(
      BuildContext context, Comment comment, int postId) async {
    final content =
        "[quote]\n${comment.author.displayName} said:\n\n${comment.body}\n[/quote]\n\n";

    Navigator.of(context).pop();
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CommentCreatePage(
          postId: widget.postId,
          initialContent: content,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
        ),
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  void _toggleDeletedComments() {
    if (_showDeleted) {
      setState(() {
        _comments = _commentsWithoutDeleted;
        _showDeleted = false;
      });
    } else {
      setState(() {
        _comments = _commentsWithDeleted;
        _showDeleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
          //TODO: questionable feature
          // actions: <Widget>[
          //   Tooltip(
          //     message:
          //         commentListingTooltipsToggleDeletedComments,
          //     child: IconButton(
          //       icon: Icon(Icons.remove_red_eye),
          //       onPressed: () => _toggleDeletedComments(),
          //     ),
          //   )
          // ],
        ),
        body: SafeArea(
          child: Scaffold(
            floatingActionButton: Consumer(
              builder: (_, watch, __) {
                final isLoggedIn = watch(isLoggedInProvider);

                //TODO: comment feature is not ready yet
                return SizedBox.shrink();
                // return isLoggedIn
                //     ? OpenContainer(
                //         closedElevation: 0,
                //         closedColor: Colors.transparent,
                //         closedBuilder: (context, action) =>
                //             FloatingActionButton(
                //           child: Icon(Icons.add),
                //           onPressed: null,
                //         ),
                //         openBuilder: (context, action) =>
                //             CommentCreatePage(postId: widget.postId),
                //       )
                //     : SizedBox.shrink();
              },
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Consumer(builder: (_, watch, __) {
                      final comments = watch(_commentsProvider(widget.postId));
                      return comments.when(
                        data: (comments) {
                          _commentsWithDeleted = comments;
                          _commentsWithoutDeleted = comments
                              .where((comment) => comment.isDeleted == false)
                              .toList();

                          WidgetsBinding.instance
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
                        },
                        loading: () => Lottie.asset(
                            "assets/animations/comment_loading.json"),
                        error: (error, stackTrace) => Center(
                          child: Text("Something went wrong"),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
