// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_data.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';

class ExploreCarousel extends StatelessWidget {
  const ExploreCarousel({
    Key? key,
    required this.posts,
  }) : super(key: key);

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenSize = screenWidthToDisplaySize(size.width);
    return Container(
      width: size.width,
      constraints: BoxConstraints(maxHeight: size.height * 0.5),
      child: CarouselSlider.builder(
        itemCount: posts.length,
        itemBuilder: (context, index, realIndex) {
          final post = posts[index];
          return GestureDetector(
            onTap: () => AppRouter.router.navigateTo(
              context,
              '/post/detail',
              routeSettings: RouteSettings(
                arguments: [
                  posts
                      .map((e) => PostData(post: e, isFavorited: false))
                      .toList(),
                  index,
                ],
              ),
            ),
            child: Stack(
              children: [
                PostImage(
                  imageUrl: post.isAnimated
                      ? post.previewImageUrl
                      : post.normalImageUrl,
                  placeholderUrl: post.previewImageUrl,
                ),
                ShadowGradientOverlay(
                  alignment: Alignment.bottomCenter,
                  colors: <Color>[
                    const Color(0xC2000000),
                    Colors.black12.withOpacity(0)
                  ],
                ),
                Align(
                  alignment: const Alignment(-0.9, 1),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        options: CarouselOptions(
          aspectRatio: 1.5,
          viewportFraction: screenSizeToViewPortFraction(screenSize),
          enlargeCenterPage: true,
        ),
      ),
    );
  }
}

double screenSizeToViewPortFraction(ScreenSize size) {
  if (size == ScreenSize.large) return 0.2;
  if (size == ScreenSize.medium) return 0.3;
  return 0.4;
}
