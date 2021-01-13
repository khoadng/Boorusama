import 'package:animations/animations.dart';
import 'package:boorusama/application/comment/comment.dart';
import 'package:boorusama/application/comment/comment_state_notifier.dart';
import 'package:boorusama/presentation/comment/comment_update_page.dart';
import 'package:boorusama/presentation/comment/widgets/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'comment_create_page.dart';

final commentStateNotifierProvider =
    StateNotifierProvider<CommentStateNotifier>(
        (ref) => CommentStateNotifier(ref));

class CommentPage extends StatefulWidget {
  final int postId;

  const CommentPage({
    Key key,
    @required this.postId,
  }) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  // List<User> _users = <User>[];
  bool _showDeleted = false;
  List<Comment> _comments = <Comment>[];
  List<Comment> _commentsWithDeleted = <Comment>[];
  List<Comment> _commentsWithoutDeleted = <Comment>[];

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () => context
            .read(commentStateNotifierProvider)
            .getComments(widget.postId));
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
          actions: <Widget>[
            Tooltip(
              message: "Toggle deleted comments",
              child: IconButton(
                icon: Icon(Icons.remove_red_eye),
                onPressed: () => _toggleDeletedComments(),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Scaffold(
            floatingActionButton: OpenContainer(
              closedColor: Colors.transparent,
              closedBuilder: (context, action) => FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: null,
              ),
              openBuilder: (context, action) =>
                  CommentCreatePage(postId: widget.postId),
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ProviderListener(
                      provider: commentStateNotifierProvider.state,
                      onChange: (context, state) {
                        state.maybeWhen(
                          fetched: (comments) =>
                              _handleCommentsFetched(comments, context),
                          orElse: () => Center(
                            child: Lottie.asset(
                                "assets/animations/comment_loading.json"),
                          ),
                        );
                      },
                      child: Consumer(
                        builder: (context, watch, child) {
                          final state =
                              watch(commentStateNotifierProvider.state);
                          return state.maybeWhen(
                            fetched: (comments) =>
                                _buildCommentSection(_comments),
                            //     BlocListener<UserListBloc, UserListState>(
                            //   listener: (context, state) {
                            //     if (state is UserListFetched) {
                            //       if (_users.isEmpty) {
                            //         setState(() {
                            //           _users = state.users;
                            //         });
                            //       }
                            //     }
                            //   },
                            //   child: _buildCommentSection(_comments),
                            // ),
                            orElse: () => Center(
                              child: Lottie.asset(
                                  "assets/animations/comment_loading.json"),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCommentsFetched(List<Comment> comments, BuildContext context) {
    _commentsWithDeleted = comments;
    _commentsWithoutDeleted =
        comments.where((comment) => comment.isDeleted == false).toList();
    setState(() {
      if (_showDeleted) {
        _comments = _commentsWithDeleted;
      } else {
        _comments = _commentsWithoutDeleted;
      }
    });
  }

  Widget _buildCommentSection(List<Comment> comments) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              onLongPress: () => showMaterialModalBottomSheet(
                context: context,
                builder: (context, controller) => Material(
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text('Edit'),
                          leading: Icon(Icons.edit),
                          onTap: () =>
                              _handleEditTap(context, comment, widget.postId),
                        ),
                        ListTile(
                          title: Text('Reply'),
                          leading: Icon(Icons.folder_open),
                          onTap: () =>
                              _handleReplyTap(context, comment, widget.postId),
                        ),
                        ListTile(
                          title: Text('Delete'),
                          leading: Icon(Icons.delete),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        child: Text("There are no comments."),
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
          initialContent: comment.content,
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
        "[quote]\n${comment.author.name} said:\n\n${comment.content}\n[/quote]\n\n";

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
}
