// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/details_page_desktop.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/posts/file_details_section.dart';
import 'package:boorusama/boorus/core/widgets/posts/source_section.dart';
import 'package:boorusama/boorus/core/widgets/tags/post_tag_list.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'moebooru_information_section.dart';

class MoebooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int index) onExit;

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
    final booruConfig = ref.watch(currentBooruConfigProvider);

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
          );
        },
        infoBuilder: (context) {
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    MoebooruInformationSection(post: post),
                    const Divider(
                      thickness: 1.5,
                    ),
                    MoebooruPostActionToolbar(post: post),
                    const Divider(
                      thickness: 1.5,
                      height: 4,
                    ),
                    FileDetailsSection(
                      post: post,
                    ),
                    const Divider(
                      thickness: 1.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: PostTagList(
                        tags: ref.watch(tagsProvider(booruConfig)),
                        onTap: (tag) => goToSearchPage(
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
