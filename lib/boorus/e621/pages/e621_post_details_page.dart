// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'widgets/e621_post_action_toolbar.dart';
import 'widgets/e621_post_tag_list.dart';

class E621PostDetailsPage extends ConsumerStatefulWidget {
  const E621PostDetailsPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onExit,
  });

  final int intitialIndex;
  final List<E621Post> posts;
  final void Function(int page) onExit;

  @override
  ConsumerState<E621PostDetailsPage> createState() =>
      _E621PostDetailsPageState();
}

class _E621PostDetailsPageState extends ConsumerState<E621PostDetailsPage> {
  List<E621Post> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.intitialIndex,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(context, tag: tag),
      toolbarBuilder: (context, post) => E621PostActionToolbar(post: post),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
          ? post.artistTags
              .map((tag) => ArtistPostList2(
                    tag: tag,
                    builder: (tag) => ref
                        .watch(e621ArtistPostsProvider(tag))
                        .maybeWhen(
                          data: (data) => SliverPreviewPostGrid(
                            posts: data,
                            onTap: (postIdx) => goToPostDetailsPage(
                              context: context,
                              posts: data,
                              initialIndex: postIdx,
                            ),
                            imageUrl: (item) => item.thumbnailFromSettings(
                                ref.watch(settingsProvider)),
                          ),
                          orElse: () => const SliverPreviewPostGridPlaceholder(
                            itemCount: 30,
                          ),
                        ),
                  ))
              .toList()
          : [],
      tagListBuilder: (context, post) => E621TagsTile(post: post),
      infoBuilder: (context, post) => SimpleInformationSection(
        post: post,
        showSource: true,
      ),
      placeholderImageUrlBuilder: (post, currentPage) =>
          currentPage == widget.intitialIndex && post.isTranslated
              ? null
              : post.thumbnailImageUrl,
      imageOverlayBuilder: (constraints, post) {
        final noteState = ref.watch(notesControllerProvider(post));
        return noteOverlayBuilderDelegate(constraints, post, noteState);
      },
      topRightButtonsBuilder: (page, expanded, post) {
        final noteState = ref.watch(notesControllerProvider(post));

        return [
          NoteActionButton(
            post: post,
            showDownload: !expanded && noteState.notes.isEmpty,
            enableNotes: noteState.enableNotes,
            onDownload: () =>
                ref.read(notesControllerProvider(post).notifier).load(),
            onToggleNotes: () => ref
                .read(notesControllerProvider(post).notifier)
                .toggleNoteVisibility(),
          ),
          GeneralMoreActionButton(
            post: post,
          ),
        ];
      },
      sourceSectionBuilder: (context, post) => const SizedBox.shrink(),
      artistInfoBuilder: (context, post) => E621ArtistSection(post: post),
    );
  }
}

class E621ArtistSection extends ConsumerWidget {
  const E621ArtistSection({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentary = post.description;

    return ArtistSection(
      //FIXME: shouldn't use danbooru's artist section, should separate it
      commentary: ArtistCommentary(
        originalTitle: '',
        originalDescription: commentary,
        translatedTitle: '',
        translatedDescription: '',
      ),
      artistTags: post.artistTags,
      source: post.source,
    );
  }
}

class E621TagsTile extends ConsumerWidget {
  const E621TagsTile({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: context.theme.copyWith(
        listTileTheme: context.theme.listTileTheme.copyWith(
          visualDensity: VisualDensity.compact,
        ),
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: E621PostTagList(post: post),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
