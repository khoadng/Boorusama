import 'package:boorusama/application/comments/bloc/comment_bloc.dart';
import 'package:boorusama/application/users/bloc/user_list_bloc.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:boorusama/presentation/comments/widgets/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

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
  CommentBloc _commentBloc;
  UserListBloc _userListBloc;
  List<User> _users;

  @override
  void initState() {
    super.initState();
    _commentBloc = BlocProvider.of<CommentBloc>(context)
      ..add(GetCommentsFromPostIdRequested(widget.postId));
    _userListBloc = BlocProvider.of<UserListBloc>(context);
    _users = <User>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentFetched) {
                  if (state.comments.isNotEmpty) {
                    final userList = <String>[];
                    state.comments.forEach((comment) {
                      userList.add(comment.creatorId.toString());
                    });
                    _userListBloc.add(UserListRequested(userList.join(",")));
                    return BlocListener<UserListBloc, UserListState>(
                      listener: (context, state) {
                        if (state is UserListFetched) {
                          if (_users.isEmpty) {
                            setState(() {
                              _users = state.users;
                            });
                          }
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemBuilder: (context, index) => CommentItem(
                              comment: state.comments[index],
                              user: _users.isNotEmpty
                                  ? _users
                                      .where((user) =>
                                          user.id ==
                                          state.comments[index].creatorId)
                                      .first
                                  : User.placeholder(),
                            ),
                            itemCount: state.comments.length,
                          )),
                    );
                  } else {
                    return Center(
                      child: Text("There are no comments."),
                    );
                  }
                } else {
                  return Center(
                    child:
                        Lottie.asset("assets/animations/comment_loading.json"),
                  );
                }
              },
            ),
          ))
        ],
      ),
    );
  }
}
