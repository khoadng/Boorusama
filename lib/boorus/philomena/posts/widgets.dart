// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/artists/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import 'providers.dart';
import 'types.dart';

class PhilomenaStatsTileSection extends ConsumerWidget {
  const PhilomenaStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: SimplePostStatsTile(
        totalComments: post.commentCount,
        favCount: post.favCount,
        score: post.score,
        votePercentText: _generatePercentText(post),
      ),
    );
  }

  String _generatePercentText(PhilomenaPost? post) {
    if (post == null) return '';
    final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
    return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
  }
}

class PhilomenaArtistInfoSection extends ConsumerWidget {
  const PhilomenaArtistInfoSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ArtistCommentary.description(post.description),
        artistTags: post.artistTags ?? {},
        source: post.source,
      ),
    );
  }
}

class PhilomenaUploaderFileDetailTile extends ConsumerWidget {
  const PhilomenaUploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: switch (ref.watch(philomenaUploaderQueryProvider(post))) {
          final query? => () => goToSearchPage(
            ref,
            tag: query.resolveTag(),
          ),
          _ => null,
        },
      ),
    };
  }
}

class PhilomenaUploaderPostsSection extends ConsumerWidget {
  const PhilomenaUploaderPostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return UploaderPostsSection<PhilomenaPost>(
      query: ref.watch(
        philomenaUploaderQueryProvider(post),
      ),
    );
  }
}

final kPhilomenaPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<PhilomenaPost>(),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<PhilomenaPost>(),
  },
  full: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<PhilomenaPost>(),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<PhilomenaPost>(),
    DetailsPart.artistInfo: (context) => const PhilomenaArtistInfoSection(),
    DetailsPart.stats: (context) => const PhilomenaStatsTileSection(),
    DetailsPart.source: (context) =>
        const DefaultInheritedSourceSection<PhilomenaPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedBasicTagsTile<PhilomenaPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<PhilomenaPost>(
          uploader: PhilomenaUploaderFileDetailTile(),
        ),
    DetailsPart.uploaderPosts: (context) =>
        const PhilomenaUploaderPostsSection(),
  },
);
