import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/features/home/post_image.dart';
import 'package:boorusama/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SliverPostGrid extends StatelessWidget {
  const SliverPostGrid({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          if (index != null) {
            final post = posts[index];
            final items = <Widget>[];
            final image = PostImage(
              imageUrl: post.isAnimated
                  ? post.previewImageUri.toString()
                  : post.normalImageUri.toString(),
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
                GestureDetector(
                  onTap: () => AppRouter.router.navigateTo(context, "/posts",
                      routeSettings: RouteSettings(
                          arguments: [post, "${key.toString()}_${post.id}"])),
                  child:
                      Hero(tag: "${key.toString()}_${post.id}", child: image),
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
          // return StaggeredTile.fit(2);
          return StaggeredTile.extent(
              1, MediaQuery.of(context).size.height * 0.3);
          // double extent = MediaQuery.of(context).size.height / 3;
          // if (index != null) {
          //   final height = posts[index].height / 5;
          //   double mainAxisExtent;

          //   if (height > extent) {
          //     mainAxisExtent = extent;
          //     // } else if (height < 80) {
          //     //   mainAxisExtent = 80;
          //   } else {
          //     mainAxisExtent = height;
          //   }
          //   return StaggeredTile.extent(1, mainAxisExtent);
          // } else {
          //   return StaggeredTile.extent(1, extent);
          // }
        },
      ),
    );
  }
}
