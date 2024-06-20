// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'widgets/moebooru_comment_section.dart';
import 'widgets/moebooru_information_section.dart';

class MoebooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsDesktopPage({
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
      _MoebooruPostDetailsDesktopPageState();
}

class _MoebooruPostDetailsDesktopPageState
    extends ConsumerState<MoebooruPostDetailsDesktopPage> with DebounceMixin {
  late var page = widget.initialIndex;
  Timer? _debounceTimer;
  var loading = false;

  @override
  void dispose() {
    super.dispose();
    _debounceTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[page];
    final booruConfig = ref.watchConfig;

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
            loading = true;
          });
          ref
              .read(tagsProvider(booruConfig).notifier)
              .load(widget.posts[page].tags);
          _debounceTimer?.cancel();
          _debounceTimer = Timer(
            const Duration(seconds: 1),
            () {
              setState(() => loading = false);
            },
          );
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
                    MoebooruInformationSection(
                      post: post,
                      tags: ref.watch(tagsProvider(booruConfig)),
                    ),
                    const Divider(
                      thickness: 1.5,
                    ),
                    SimplePostActionToolbar(post: post),
                    const Divider(
                      thickness: 1.5,
                      height: 4,
                    ),
                    FileDetailsSection(
                      post: post,
                      rating: post.rating,
                    ),
                    const Divider(
                      thickness: 1.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TagsTile(
                        post: post,
                        tags: ref.watch(tagsProvider(booruConfig)),
                        onTagTap: (tag) => goToSearchPage(
                          context,
                          tag: tag.rawName,
                        ),
                      ),
                    ),
                    post.source.whenWeb(
                      (source) => SourceSection(source: source),
                      () => const SizedBox.shrink(),
                    ),
                    MoebooruCommentSection(
                      post: post,
                      allowFetch: !loading,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
