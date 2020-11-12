import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/post_list_swipe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PostList extends StatefulWidget {
  PostList(
      {Key key,
      @required this.posts,
      @required this.onMaxItemReached,
      @required this.scrollThreshold,
      @required this.scrollController,
      this.onScrollDirectionChanged})
      : super(key: key);

  final List<Post> posts;
  final VoidCallback onMaxItemReached;
  final ValueChanged<ScrollDirection> onScrollDirectionChanged;
  final scrollThreshold;
  final scrollController;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  bool _isScrollingDown = false;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: _buildGrid,
    );
  }

  Widget _buildGrid(BuildContext context, Orientation orientation) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CustomScrollView(
        controller: widget.scrollController..addListener(_onScroll),
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.all(42.0),
                )
              ],
            ),
          ),
          SliverStaggeredGrid.extentBuilder(
            maxCrossAxisExtent: 150,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              final items = <Widget>[];
              final image = PostImage(
                imageUrl: post.previewImageUri.toString(),
              );

              if (post.isFavorited) {
                items.add(
                  Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  ),
                );
              }

              if (post.isAnimated) {
                items.add(
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                  ),
                );
              }

              if (post.isTranslated) {
                items.add(
                  Icon(
                    Icons.g_translate_outlined,
                    color: Colors.white70,
                  ),
                );
              }

              if (post.hasComment) {
                items.add(
                  Icon(
                    Icons.comment,
                    color: Colors.white70,
                  ),
                );
              }

              return Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostListSwipePage(
                        posts: widget.posts,
                        initialPostIndex: index,
                        postHeroTag: "postHero$index",
                      ),
                    )),
                    child: Hero(tag: "postHero$index", child: image),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      children: items,
                    ),
                  )
                ],
              );
            },
            staggeredTileBuilder: (index) {
              final height =
                  index != null ? widget.posts[index].height / 10 : 0;
              double mainAxisExtent;

              if (height > 150) {
                mainAxisExtent = 150;
              } else if (height < 80) {
                mainAxisExtent = 80;
              } else {
                mainAxisExtent = height;
              }
              return StaggeredTile.extent(1, mainAxisExtent);
            },
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;
    final currentThresholdPercent = currentScroll / maxScroll;

    if (currentThresholdPercent >= widget.scrollThreshold) {
      widget.onMaxItemReached?.call();
    }

    if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        widget.onScrollDirectionChanged?.call(ScrollDirection.reverse);
      }
    } else if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        widget.onScrollDirectionChanged?.call(ScrollDirection.forward);
      }
    }
  }
}
