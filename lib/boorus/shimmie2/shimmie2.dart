// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';

class Shimmie2Builder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        NoteNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        NoGranularRatingQueryBuilderMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const Shimmie2Builder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final AutocompleteRepository autocompleteRepo;
  final PostRepository postRepo;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateAnonConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat: null,
            ),
            backgroundColor: backgroundColor,
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateAnonConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher =>
      (page, tags, {limit}) => postRepo.getPosts(tags, page, limit: limit);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder, ref) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
              tagListBuilder: (context, post) => BasicTagList(
                tags: post.tags,
                unknownCategoryColor: ref.getTagColor(
                  context,
                  'general',
                ),
                onTap: (tag) => goToSearchPage(context, tag: tag),
              ),
              fileDetailsBuilder: (context, post) => FileDetailsSection(
                post: post,
                rating: post.rating,
                uploader: castOrNull<SimplePost>(post).toOption().fold(
                    () => null,
                    (t) => t.uploaderName != null
                        ? Text(
                            t.uploaderName!.replaceAll('_', ' '),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          )
                        : null),
              ),
            ),
          );

  @override
  DownloadFilenameGenerator<Post> get downloadFilenameBuilder =>
      LegacyFilenameBuilder(
        generateFileName: (post, downloadUrl) => basename(downloadUrl),
      );
}
