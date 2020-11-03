import 'package:boorusama/application/comments/bloc/comment_bloc.dart';
import 'package:boorusama/domain/comments/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
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

  @override
  void initState() {
    super.initState();
    _commentBloc = BlocProvider.of<CommentBloc>(context)
      ..add(GetCommentsFromPostIdRequested(widget.postId));
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
                    return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemBuilder: (context, index) =>
                              ForumPost(state.comments[index]),
                          itemCount: state.comments.length,
                        ));
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

class ForumPost extends StatelessWidget {
  final Comment comment;

  ForumPost(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: ThemeData.dark().backgroundColor,
        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple[300],
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 50.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(comment.creatorId.toString()),
                      // Text(entry.hours),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
            padding: const EdgeInsets.all(8.0),
            child: Html(
              data: comment.body,
            ),
          ),
        ],
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Color iconColor;

  IconWithText(this.iconData, this.text, {this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Icon(
            this.iconData,
            color: this.iconColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(this.text),
          ),
        ],
      ),
    );
  }
}
