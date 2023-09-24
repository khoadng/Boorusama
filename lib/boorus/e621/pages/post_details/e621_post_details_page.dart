// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/artist_section.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/note_action_button.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/pages/popular/e621_post_tag_list.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'e621_information_section.dart';
import 'e621_post_action_toolbar.dart';
import 'e621_recommended_artist_list.dart';

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
    final settings = ref.watch(settingsProvider);

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.intitialIndex,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(context, tag: tag),
      toolbarBuilder: (context, post) => E621PostActionToolbar(post: post),
      sliverArtistPostsBuilder: (context, post) =>
          E621RecommendedArtistList(post: post),
      tagListBuilder: (context, post) => E621TagsTile(post: post),
      infoBuilder: (context, post) => E621InformationSection(
        post: post,
        showSource: true,
      ),
      swipeImageUrlBuilder: (post) => post.thumbnailFromSettings(settings),
      placeholderImageUrlBuilder: (post, currentPage) =>
          currentPage == widget.intitialIndex && post.isTranslated
              ? null
              : post.thumbnailImageUrl,
      imageOverlayBuilder: (constraints, post) {
        final noteState = ref.watch(notesControllerProvider(post));
        return noteOverlayBuilderDelegate(constraints, post, noteState);
      },
      topRightButtonsBuilder: (page, expanded) {
        final post = posts[page];
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
      showSourceTile: false,
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
      data: context.theme.copyWith(dividerColor: Colors.transparent),
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
