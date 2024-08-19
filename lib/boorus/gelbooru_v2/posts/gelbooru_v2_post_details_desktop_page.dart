// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/artists/artists.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'gelbooru_v2_post_details_page.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return false;
});

class GelbooruV2PostDetailsDesktopPage extends ConsumerStatefulWidget {
  const GelbooruV2PostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<GelbooruV2PostDetailsDesktopPage> with DebounceMixin {
  late var page = widget.initialIndex;
  Timer? _debounceTimer;

  @override
  void dispose() {
    super.dispose();
    _debounceTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[page];
    final gelArtistMap = ref.watch(gelbooruV2PostDetailsArtistMapProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToOriginalImagePage(context, post),
      },
      child: DetailsPageDesktop(
        onExit: widget.onExit,
        initialPage: widget.initialIndex,
        totalPages: widget.posts.length,
        onPageChanged: (page) {
          widget.onPageChanged(page);
          setState(() {
            this.page = page;

            ref.read(allowFetchProvider.notifier).state = false;

            _debounceTimer?.cancel();
            _debounceTimer = Timer(
              const Duration(seconds: 1),
              () {
                ref.read(allowFetchProvider.notifier).state = true;
              },
            );
          });
        },
        topRightBuilder: (context) => GeneralMoreActionButton(
          post: post,
        ),
        mediaBuilder: (context) {
          return PostMedia(
            post: post,
            imageUrl: post.sampleImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            autoPlay: true,
            inFocus: true,
          );
        },
        infoBuilder: (context) {
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FileDetailsSection(
                      post: post,
                      rating: post.rating,
                    ),
                    const Divider(height: 8, thickness: 1),
                    SimplePostActionToolbar(post: post),
                    const Divider(height: 8, thickness: 1),
                    GelbooruV2TagsTile(post: post),
                  ],
                ),
              ),
              if (allowFetch)
                gelArtistMap.lookup(post.id).fold(
                      () => const SliverSizedBox.shrink(),
                      (tags) => tags.isNotEmpty
                          ? ArtistPostList(
                              artists: tags,
                              builder: (tag) => ref
                                  .watch(gelbooruV2ArtistPostsProvider(tag))
                                  .maybeWhen(
                                    data: (data) => PreviewPostGrid(
                                      posts: data,
                                      onTap: (postIdx) => goToPostDetailsPage(
                                        context: context,
                                        posts: data,
                                        initialIndex: postIdx,
                                      ),
                                      imageUrl: (item) => item.sampleImageUrl,
                                    ),
                                    orElse: () =>
                                        const PreviewPostGridPlaceholder(
                                      
                                    ),
                                  ),
                            )
                          : const SliverSizedBox.shrink(),
                    ),
              const SliverSizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  bool get allowFetch => ref.watch(allowFetchProvider);
}
