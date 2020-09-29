import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostListPage extends StatefulWidget {
  PostListPage({Key key}) : super(key: key);

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Boorusama")),
        body: Container(
          child: BlocBuilder<PostListBloc, PostListState>(
            builder: (context, state) {
              if (state is PostListInitial) {
                return buildInitial();
              } else if (state is PostListLoading) {
                return buildLoading();
              } else if (state is PostListLoaded) {
                return buildListWithData(context, state.posts);
              } else {
                return buildError();
              }
            },
          ),
        ));
  }

  Widget buildInitial() {
    return Center(
      child: PostInputField(),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildListWithData(BuildContext context, List<Post> posts) {
    return PostList(
      posts: posts,
    );
  }

  Widget buildError() {
    return Center(
      child: Text("OOPS something went wrong"),
    );
  }
}

class PostInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        onSubmitted: (value) => submit(context, value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  void submit(BuildContext context, String tagString) {
    final postListBloc = BlocProvider.of<PostListBloc>(context);

    postListBloc.add(GetPost(tagString, 1));
  }
}
