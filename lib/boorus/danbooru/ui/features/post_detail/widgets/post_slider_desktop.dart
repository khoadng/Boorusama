// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';
import 'post_media_item.dart';

class PostSliderDesktop extends StatefulWidget {
  const PostSliderDesktop({
    super.key,
    required this.posts,
    required this.imagePath,
    required this.controller,
  });

  final List<PostData> posts;
  final ValueNotifier<String?> imagePath;
  final CarouselController controller;

  @override
  State<PostSliderDesktop> createState() => _PostSliderDesktopState();
}

class _PostSliderDesktopState extends State<PostSliderDesktop> {
  var enableSwipe = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostDetailBloc>().state;

    return CarouselSlider.builder(
      carouselController: widget.controller,
      itemCount: widget.posts.length,
      itemBuilder: (context, index, realIndex) {
        final media = PostMediaItem(
          //TODO: this is used to preload image between page
          post: widget.posts[index].post,
          onCached: (path) => widget.imagePath.value = path,
          enableNotes: state.enableNotes,
          notes: state.currentPost.notes,
          previewCacheManager: context.read<PreviewImageCacheManager>(),
          onTap: () => context
              .read<PostDetailBloc>()
              .add(PostDetailOverlayVisibilityChanged(
                enableOverlay: !state.enableOverlay,
              )),
          onZoomUpdated: (zoom) {
            final swipe = !zoom;
            if (swipe != enableSwipe) {
              setState(() {
                enableSwipe = swipe;
              });
            }
          },
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: media,
          ),
        );
      },
      options: CarouselOptions(
        scrollPhysics: enableSwipe
            ? const DetailPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        onPageChanged: (index, reason) {
          context
              .read<PostDetailBloc>()
              .add(PostDetailIndexChanged(index: index));
        },
        height: MediaQuery.of(context).size.height,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        initialPage: state.currentIndex,
        autoPlay: state.enableSlideShow,
        autoPlayAnimationDuration: state.slideShowConfig.skipAnimation
            ? const Duration(microseconds: 1)
            : const Duration(milliseconds: 600),
        autoPlayInterval:
            Duration(seconds: state.slideShowConfig.interval.toInt()),
      ),
    );
  }
}

class DetailPageViewScrollPhysics extends ScrollPhysics {
  const DetailPageViewScrollPhysics({super.parent});

  @override
  DetailPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DetailPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
