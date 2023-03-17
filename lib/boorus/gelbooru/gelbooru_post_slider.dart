// Flutter imports:
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_post_media_item.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';

class GelbooruPostSlider extends StatefulWidget {
  const GelbooruPostSlider({
    super.key,
    required this.posts,
    required this.imagePath,
    required this.initialPage,
  });

  final List<Post> posts;
  final ValueNotifier<String?> imagePath;
  final int initialPage;

  @override
  State<GelbooruPostSlider> createState() => _PostSliderState();
}

class _PostSliderState extends State<GelbooruPostSlider> {
  var enableSwipe = true;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.posts.length,
      itemBuilder: (context, index, realIndex) {
        final media = GelbooruPostMediaItem(
          //TODO: this is used to preload image between page
          post: widget.posts[index],
          onCached: (path) => widget.imagePath.value = path,
          previewCacheManager: context.read<PreviewImageCacheManager>(),
          // onTap: () => context
          //     .read<PostDetailBloc>()
          //     .add(PostDetailOverlayVisibilityChanged(
          //       enableOverlay: !state.enableOverlay,
          //     )),
          onZoomUpdated: (zoom) {
            final swipe = !zoom;
            if (swipe != enableSwipe) {
              setState(() {
                enableSwipe = swipe;
              });
            }
          },
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocBuilder<SettingsCubit, SettingsState>(
              buildWhen: (previous, current) =>
                  previous.settings.actionBarDisplayBehavior !=
                  current.settings.actionBarDisplayBehavior,
              builder: (context, settingsState) {
                return Stack(
                  children: [
                    _CarouselContent(
                      media: media,
                      imagePath: widget.imagePath,
                      actionBarDisplayBehavior:
                          settingsState.settings.actionBarDisplayBehavior,
                      post: widget.posts[index],
                      preloadPost: widget.posts[index],
                      // recommends: state.recommends,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
      options: CarouselOptions(
        scrollPhysics: enableSwipe
            ? const DetailPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        onPageChanged: (index, reason) {
          context
              .read<SliverPostGridBloc>()
              .add(SliverPostGridItemChanged(index: index));
        },
        height: MediaQuery.of(context).size.height,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        initialPage: widget.initialPage,
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

class _CarouselContent extends StatefulWidget {
  const _CarouselContent({
    required this.media,
    required this.imagePath,
    required this.actionBarDisplayBehavior,
    required this.post,
    required this.preloadPost,
  });

  final GelbooruPostMediaItem media;
  final ValueNotifier<String?> imagePath;
  final Post post;
  final Post preloadPost;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;

  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  Post get post => widget.post;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              RepaintBoundary(child: widget.media),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // InformationSection(post: widget.preloadPost),
                  // const Divider(height: 8, thickness: 1),
                  // if (widget.actionBarDisplayBehavior ==
                  //     ActionBarDisplayBehavior.scrolling) ...[
                  //   RepaintBoundary(
                  //     child: ActionBar(
                  //       imagePath: widget.imagePath,
                  //       postData: widget.post,
                  //     ),
                  //   ),
                  //   const Divider(height: 8, thickness: 1),
                  // ],
                  // ArtistSection(post: widget.preloadPost),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 8),
                  //   child: RepaintBoundary(child: PostStatsTile(post: post)),
                  // ),
                  // if (widget.preloadPost.hasParentOrChildren)
                  //   _ParentChildTile(post: widget.preloadPost),
                  if (!widget.preloadPost.hasParentOrChildren)
                    const Divider(height: 8, thickness: 1),
                  // TagsTile(post: post),
                  const Divider(height: 8, thickness: 1),
                  FileDetailsSection(
                    post: post,
                  ),
                  // const Divider(height: 8, thickness: 1),
                  // RecommendArtistList(
                  //   recommends: widget.recommends
                  //       .where(
                  //           (element) => element.type == RecommendType.artist)
                  //       .toList(),
                  // ),
                  // RecommendCharacterList(
                  //   recommends: widget.recommends
                  //       .where((element) =>
                  //           element.type == RecommendType.character)
                  //       .toList(),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// // ignore: prefer-single-widget-per-file
// class TagsTile extends StatelessWidget {
//   const TagsTile({
//     super.key,
//     required this.post,
//   });

//   final Post post;

//   @override
//   Widget build(BuildContext context) {
//     final tags = context.select((PostDetailBloc bloc) =>
//         bloc.state.tags.where((e) => e.postId == post.id).toList());

//     return Theme(
//       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//       child: ExpansionTile(
//         title: Text('${tags.length} tags'),
//         controlAffinity: ListTileControlAffinity.leading,
//         onExpansionChanged: (value) => value
//             ? context.read<TagBloc>().add(TagFetched(tags: post.tags))
//             : null,
//         children: const [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: PostTagList(),
//           ),
//           SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }

// class _ParentChildTile extends StatelessWidget {
//   const _ParentChildTile({
//     required this.post,
//   });

//   final Post post;

//   @override
//   Widget build(BuildContext context) {
//     return ParentChildTile(
//       data: getParentChildData(post),
//       onTap: (data) => goToParentChildPage(
//         context,
//         data.parentId,
//         data.tagQueryForDataFetching,
//       ),
//     );
//   }
// }

// ignore: prefer-single-widget-per-file
// class ActionBar extends StatelessWidget {
//   const ActionBar({
//     super.key,
//     required this.imagePath,
//     required this.postData,
//   });

//   final ValueNotifier<String?> imagePath;
//   final PostData postData;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<String?>(
//       valueListenable: imagePath,
//       builder: (context, value, child) => PostActionToolbar(
//         postData: postData,
//         imagePath: value,
//       ),
//     );
//   }
// }
