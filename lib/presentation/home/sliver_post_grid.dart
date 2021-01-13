import 'package:animations/animations.dart';
import 'package:boorusama/application/home/post_view_model.dart';
import 'package:boorusama/presentation/post_detail/post_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'post_image.dart';

class SliverPostList extends StatelessWidget {
  const SliverPostList({
    Key key,
    @required this.length,
    @required this.posts,
  }) : super(key: key);

  final int length;
  final List<PostViewModel> posts;

  @override
  Widget build(BuildContext context) {
    return SliverStaggeredGrid.extentBuilder(
      maxCrossAxisExtent: 150,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      itemCount: length,
      itemBuilder: (context, index) {
        if (index != null) {
          final post = posts[index];
          final items = <Widget>[];
          final image = PostImage(
            imageUrl: post.lowResSource,
          );

          // if (post.isFavorited) {
          //   items.add(
          //     Icon(
          //       Icons.favorite,
          //       color: Colors.redAccent,
          //     ),
          //   );
          // }

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
              // GestureDetector(
              //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => PostDetailPage(
              //       postId: post.id,
              //     ),
              //   )),
              //   child: image,
              // ),
              OpenContainer(
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                closedBuilder: (context, action) => image,
                openBuilder: (context, action) =>
                    PostDetailPage(postId: post.id),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: items,
                ),
              )
            ],
          );
        } else {
          return Center();
        }
      },
      staggeredTileBuilder: (index) {
        if (index != null) {
          final height = posts[index].height / 10;
          double mainAxisExtent;

          if (height > 150) {
            mainAxisExtent = 150;
          } else if (height < 80) {
            mainAxisExtent = 80;
          } else {
            mainAxisExtent = height;
          }
          return StaggeredTile.extent(1, mainAxisExtent);
        } else {
          return StaggeredTile.extent(1, 150);
        }
      },
    );
  }
}
