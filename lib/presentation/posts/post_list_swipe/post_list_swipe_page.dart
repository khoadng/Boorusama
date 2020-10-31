import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:flip_card/flip_card.dart';
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
  PostDownloadBloc _postDownloadBloc;
  TagListBloc _tagListBloc;
  List<Tag> _tags;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  PostImageController _postImageController;

  @override
  void initState() {
    super.initState();
    _postDownloadBloc = BlocProvider.of<PostDownloadBloc>(context);
    _tagListBloc = BlocProvider.of<TagListBloc>(context);
    _tags = List<Tag>();
    _postImageController = PostImageController();
  }

  @override
  void dispose() {
    _postImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        actions: <Widget>[
          PopupMenuButton<PostAction>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
              const PopupMenuItem<PostAction>(
                value: PostAction.foo,
                child: Text('Foo'),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: Icon(Icons.download_rounded),
                backgroundColor: Colors.red,
                label: 'Download',
                labelStyle: TextStyle(fontSize: 18.0),
                onTap: () => _postDownloadBloc.add(PostDownloadRequested(
                    post: widget.posts[_currentPostIndex]))),
            SpeedDialChild(
              child: Icon(Icons.tag),
              backgroundColor: Colors.blue,
              label: 'Tags',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _tagListBloc.add(GetTagList(
                  widget.posts[_currentPostIndex].tagString.toCommaFormat(),
                  1)),
            ),
            SpeedDialChild(
              child: Icon(Icons.translate_rounded),
              backgroundColor: Colors.green,
              label: 'Notes',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _postImageController.toggleTranslationNotes(),
            ),
          ]),
      body: BlocListener<TagListBloc, TagListState>(
        listener: (context, state) {
          if (state is TagListLoaded) {
            setState(() {
              _tags = state.tags;
              cardKey.currentState.toggleCard();
            });
          }
        },
        child: FlipCard(
          key: cardKey,
          flipOnTouch: false,
          back: PostInfo(tags: _tags),
          front: PostListSwipe(
            postImageController: _postImageController,
            posts: widget.posts,
            onPostChanged: (value) => _currentPostIndex = value,
            initialPostIndex: widget.initialPostIndex,
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
