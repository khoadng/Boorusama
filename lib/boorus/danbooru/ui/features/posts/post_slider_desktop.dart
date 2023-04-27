// // Flutter imports:
// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// // Project imports:
// import 'package:boorusama/boorus/danbooru/application/posts.dart';
// import 'package:boorusama/boorus/danbooru/domain/posts.dart';
// import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/danbooru_post_media_item.dart';
// import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';

// class PostSliderDesktop extends StatelessWidget {
//   const PostSliderDesktop({
//     super.key,
//     required this.posts,
//     required this.imagePath,
//     required this.controller,
//   });

//   final List<DanbooruPost> posts;
//   final ValueNotifier<String?> imagePath;
//   final CarouselController controller;

//   @override
//   Widget build(BuildContext context) {
//     final state = context.watch<PostDetailBloc>().state;

//     return CarouselSlider.builder(
//       carouselController: controller,
//       itemCount: posts.length,
//       itemBuilder: (context, index, realIndex) {
//         final media = DanbooruPostMediaItem(
//           //TODO: this is used to preload image between page
//           post: posts[index],
//           onCached: (path) => imagePath.value = path,
//           enableNotes: state.enableNotes,
//           notes: [],
//           previewCacheManager: context.read<PreviewImageCacheManager>(),
//           onTap: () => context
//               .read<PostDetailBloc>()
//               .add(PostDetailOverlayVisibilityChanged(
//                 enableOverlay: !state.enableOverlay,
//               )),
//         );

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Center(
//             child: media,
//           ),
//         );
//       },
//       options: CarouselOptions(
//         scrollPhysics: const NeverScrollableScrollPhysics(),
//         onPageChanged: (index, reason) {
//           context
//               .read<PostDetailBloc>()
//               .add(PostDetailIndexChanged(index: index));
//         },
//         height: MediaQuery.of(context).size.height,
//         viewportFraction: 1,
//         enableInfiniteScroll: false,
//         initialPage: state.currentIndex,
//       ),
//     );
//   }
// }
