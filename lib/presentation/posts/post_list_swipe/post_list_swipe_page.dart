import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class PostListSwipePage extends StatefulWidget {
  PostListSwipePage({Key key, @required this.posts, this.initialPostIndex})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;

  @override
  _PostListSwipePageState createState() => _PostListSwipePageState();
}

class _PostListSwipePageState extends State<PostListSwipePage> {
  int _currentPostIndex;
  bool _currentPostIsFaved = false;
  PostDownloadBloc _postDownloadBloc;
  PostFavoritesBloc _postFavoritesBloc;
  TagListBloc _tagListBloc;
  List<Tag> _tags;
  PostImageController _postImageController;

  @override
  void initState() {
    super.initState();
    _postDownloadBloc = BlocProvider.of<PostDownloadBloc>(context);
    _postFavoritesBloc = BlocProvider.of<PostFavoritesBloc>(context);
    _tagListBloc = BlocProvider.of<TagListBloc>(context);
    _tags = List<Tag>();
    _postImageController = PostImageController();
    //TODO: data maybe stale, should change to other logic
    _currentPostIsFaved = widget.posts[widget.initialPostIndex].isFavorited;
  }

  @override
  void dispose() {
    _postImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap: (value) {
              if (value == 1) {
                _tagListBloc.add(GetTagList(
                    widget.posts[_currentPostIndex].tagString.toCommaFormat(),
                    1));
              }
            },
            tabs: [
              Tab(icon: Icon(Icons.image)),
              Tab(icon: Icon(Icons.info)),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.translate),
              onPressed: () => _postImageController.toggleTranslationNotes(),
            ),
            PopupMenuButton<PostAction>(
              offset: Offset(0, 200),
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PostAction>>[
                const PopupMenuItem<PostAction>(
                  value: PostAction.foo,
                  child: Text('Placeholder'),
                ),
              ],
            )
          ],
        ),
        floatingActionButton: MultiBlocListener(
          listeners: [
            BlocListener<PostFavoritesBloc, PostFavoritesState>(
              listener: (context, state) {
                if (state is AddPostToFavoritesCompleted) {
                  setState(() {
                    _currentPostIsFaved = true;
                  });
                  //TODO: warning workaround, updating local data, DANGEROUS CODE
                  widget.posts[_currentPostIndex].isFavorited = true;
                } else if (state is RemovePostToFavoritesCompleted) {
                  setState(() {
                    _currentPostIsFaved = false;
                  });
                  //TODO: warning workaround, updating local data, DANGEROUS CODE
                  widget.posts[_currentPostIndex].isFavorited = false;
                } else {
                  throw Exception("Unknown state for PostFavoriteBloc");
                }
              },
            )
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () => _currentPostIsFaved
                    ? _postFavoritesBloc.add(
                        RemoveFromFavorites(widget.posts[_currentPostIndex].id))
                    : _postFavoritesBloc.add(
                        AddToFavorites(widget.posts[_currentPostIndex].id)),
                child: _currentPostIsFaved
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: () => _postDownloadBloc.add(
                  PostDownloadRequested(post: widget.posts[_currentPostIndex]),
                ),
                heroTag: null,
                child: Icon(Icons.download_rounded),
              ),
            ],
          ),
        ),
        body: BlocListener<TagListBloc, TagListState>(
          listener: (context, state) {
            if (state is TagListLoaded) {
              setState(() {
                _tags = state.tags;
              });
            }
          },
          child: TabBarView(
            children: [
              PostListSwipe(
                postImageController: _postImageController,
                posts: widget.posts,
                onPostChanged: (value) {
                  //TODO: not to reconsider, kinda ugly
                  _currentPostIsFaved = widget.posts[value].isFavorited;
                  _currentPostIndex = value;
                },
                initialPostIndex: widget.initialPostIndex,
              ),
              PostInfo(tags: _tags),
            ],
          ),
        ),
      ),
    );
  }
}

class PostInfo extends StatelessWidget {
  const PostInfo({
    Key key,
    @required List<Tag> tags,
  })  : _tags = tags,
        super(key: key);

  final List<Tag> _tags;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tags.length,
      itemBuilder: (context, index) {
        return ListTile(
            trailing: Text(_tags[index].postCount.toString(),
                style: TextStyle(color: Colors.grey)),
            title: Text(
              _tags[index].displayName,
              style: TextStyle(
                color: Color(_tags[index].tagHexColor),
              ),
            ));
      },
    );
  }
}

enum PostAction { foo }
