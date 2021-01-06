import 'package:boorusama/application/comments/bloc/comment_bloc.dart';
import 'package:boorusama/application/users/bloc/user_list_bloc.dart';
import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:boorusama/presentation/comments/widgets/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'editor_page.dart';

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
  List<User> _users = <User>[];
  final GlobalKey _fabKey = GlobalKey();
  bool _showDeleted = false;
  List<Comment> _comments = <Comment>[];
  List<Comment> _commentsWithDeleted = <Comment>[];
  List<Comment> _commentsWithoutDeleted = <Comment>[];

  @override
  void initState() {
    super.initState();
    context
        .read<CommentBloc>()
        .add(CommentEvent.requested(postId: widget.postId));
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
            floatingActionButton: _fab,
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: BlocListener<CommentBloc, CommentState>(
                      listener: (context, state) {
                        state.maybeWhen(
                          fetched: (comments) {
                            _commentsWithDeleted = comments;
                            _commentsWithoutDeleted = comments
                                .where((comment) => comment.isDeleted == false)
                                .toList();
                            setState(() {
                              if (_showDeleted) {
                                _comments = _commentsWithDeleted;
                              } else {
                                _comments = _commentsWithoutDeleted;
                              }
                            });

                            final userList = <String>[];
                            comments.forEach((comment) {
                              if (!userList
                                  .contains(comment.creatorId.toString())) {
                                userList.add(comment.creatorId.toString());
                              }
                            });
                            BlocProvider.of<UserListBloc>(context)
                                .add(UserListRequested(userList.join(",")));
                          },
                          orElse: () => Center(
                            child: Lottie.asset(
                                "assets/animations/comment_loading.json"),
                          ),
                        );
                      },
                      child: BlocListener<UserListBloc, UserListState>(
                        listener: (context, state) {
                          if (state is UserListFetched) {
                            if (_users.isEmpty) {
                              setState(() {
                                _users = state.users;
                              });
                            }
                          }
                        },
                        child: _buildCommentSection(_comments),
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

  Widget _buildCommentSection(List<Comment> comments) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, index) => CommentItem(
            comment: comments[index],
            user: _users.isNotEmpty
                ? _users
                    .where((user) => user.id == comments[index].creatorId)
                    .first
                : User.placeholder(),
          ),
          itemCount: _comments.length,
        ),
      );
    } else {
      return Center(
        child: Text("There are no comments."),
      );
    }
  }

  Widget get _fab {
    return AnimatedBuilder(
      animation: ModalRoute.of(context).animation,
      child: FloatingActionButton(
        key: _fabKey,
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          _route(),
        ),
      ),
      builder: (BuildContext context, Widget fab) {
        final Animation<double> animation = ModalRoute.of(context).animation;
        return SizedBox(
          width: 54 * animation.value,
          height: 54 * animation.value,
          child: fab,
        );
      },
    );
  }

  Route<dynamic> _route() {
    final RenderBox box = _fabKey.currentContext.findRenderObject();
    final Rect rect = box.localToGlobal(Offset.zero) & box.size;

    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, _, __) => EditorPage(
        sourceRect: rect,
        postId: widget.postId,
      ),
      transitionDuration: const Duration(milliseconds: 350),
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
