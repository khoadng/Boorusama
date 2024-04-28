// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/artists/artists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'gelbooru_post_details_page.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return false;
});

class GelbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    this.hasDetailsTagList = true,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int index) onExit;
  final bool hasDetailsTagList;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<GelbooruPostDetailsDesktopPage> with DebounceMixin {
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
    final booruConfig = ref.watchConfig;
    final gelArtistMap = ref.watch(gelbooruPostDetailsArtistMapProvider);

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

                if (widget.hasDetailsTagList) {
                  ref.read(tagsProvider(booruConfig).notifier).load(
                    post.tags,
                    onSuccess: (tags) {
                      if (!mounted) return;

                      ref.read(tagsProvider(booruConfig).notifier).load(
                        post.tags,
                        onSuccess: (tags) {
                          if (!mounted) return;
                          ref.setGelbooruPostDetailsArtistMap(
                            post: post,
                            tags: tags,
                          );
                        },
                      );
                    },
                  );
                }
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
                    TagsTile(
                      initialExpanded: true,
                      tags: ref.watch(tagsProvider(booruConfig)),
                      post: post,
                      onTagTap: (tag) =>
                          goToSearchPage(context, tag: tag.rawName),
                    ),
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
                                  .watch(gelbooruArtistPostsProvider(tag))
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
                                      imageCount: 30,
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
