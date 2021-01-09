import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/posts/post_detail/post_detail_page.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:boorusama/domain/posts/post_name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PostListSwipePage extends StatefulWidget {
  PostListSwipePage(
      {Key key, @required this.posts, this.initialPostIndex, this.postHeroTag})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;
  final String postHeroTag;

  @override
  _PostListSwipePageState createState() => _PostListSwipePageState();
}

class _PostListSwipePageState extends State<PostListSwipePage> {
  int _currentPostIndex;
  PostImageController _postImageController;
  List<Tag> _tags = <Tag>[];
  double _bodyHeight;
  PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _postImageController = PostImageController();
    _currentPostIndex = widget.initialPostIndex;
    BlocProvider.of<TagListBloc>(context).add(
      GetTagList(widget.posts[_currentPostIndex].tagString.toCommaFormat(), 1),
    );
  }

  @override
  void dispose() {
    _postImageController.dispose();
    _panelController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appbarActions = <Widget>[];
    _bodyHeight ??= (MediaQuery.of(context).size.height -
            kToolbarHeight -
            60 -
            MediaQuery.of(context).padding.top) *
        1;

    if (widget.posts[_currentPostIndex].isTranslated) {
      appbarActions.add(IconButton(
          icon: Icon(Icons.translate),
          onPressed: () => _postImageController.toggleTranslationNotes()));
    }

    appbarActions.add(
      PopupMenuButton<PostAction>(
        onSelected: (value) {
          switch (value) {
            case PostAction.download:
              context.read<PostDownloadBloc>().add(
                    PostDownloadEvent.downloaded(
                      post: widget.posts[_currentPostIndex],
                    ),
                  );
              break;
            default:
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
          PopupMenuItem<PostAction>(
            value: PostAction.download,
            child: ListTile(
              leading: const Icon(Icons.download_rounded),
              title: Text("Download"),
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 10.0, left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${widget.posts[_currentPostIndex].name.characterOnly.pretty.capitalizeFirstofEach}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle1),
                Text(
                    "${widget.posts[_currentPostIndex].name.copyRightOnly.pretty.capitalizeFirstofEach}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption),
              ],
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: appbarActions,
        ),
        body: BlocListener<TagListBloc, TagListState>(
          listener: (context, state) {
            if (state is TagListLoaded) {
              setState(() {
                _tags = state.tags;
              });
            }
          },
          child: SlidingUpPanel(
            controller: _panelController,
            onPanelSlide: (position) {
              if (_panelController.isPanelOpen) {
                setState(() {
                  _bodyHeight = (MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top) *
                      0.35;
                });
              } else if (_panelController.isPanelClosed) {
                setState(() {
                  _bodyHeight = (MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          60 -
                          MediaQuery.of(context).padding.top) *
                      1;
                });
              }
            },
            bodyHeight: _bodyHeight,
            maxHeight: (MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top) *
                0.65,
            minHeight: 60,
            panel: PostDetailPage(
              post: widget.posts[_currentPostIndex],
              tags: _tags,
            ),
            body: PostListSwipe(
              postHeroTag: widget.postHeroTag,
              postImageController: _postImageController,
              posts: widget.posts,
              onPostChanged: (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _currentPostIndex = value;
                  });
                });

                BlocProvider.of<TagListBloc>(context).add(
                  GetTagList(widget.posts[value].tagString.toCommaFormat(), 1),
                );
              },
              initialPostIndex: _currentPostIndex,
            ),
          ),
        ),
      ),
    );
  }
}

enum PostAction { download }
