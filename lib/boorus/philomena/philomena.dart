// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/philomena/create_philomena_config_page.dart';
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'philomena_post.dart';

class PhilomenaBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  PhilomenaBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final PostRepository postRepo;
  final AutocompleteRepository autocompleteRepo;

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
          CreatePhilomenaConfigPage(
            url: url,
            booruType: booruType,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(tags, page);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              artistInfoBuilder: (context, post) => ArtistSection(
                commentary: post is PhilomenaPost
                    ? ArtistCommentary(
                        originalTitle: '',
                        originalDescription: post.description,
                        translatedTitle: '',
                        translatedDescription: '',
                      )
                    : ArtistCommentary.empty(),
                artistTags: post.artistTags ?? [],
                source: post.source,
              ),
              infoBuilder: (context, post) =>
                  SimpleInformationSection(post: post),
              statsTileBuilder: (context, post) => SimplePostStatsTile(
                totalComments: post is PhilomenaPost ? post.commentCount : 0,
                favCount: post is PhilomenaPost ? post.favCount : 0,
                score: post.score,
                votePercentText: _generatePercentText(post as PhilomenaPost),
              ),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
            ),
          );
}

String _generatePercentText(PhilomenaPost? post) {
  if (post == null) return '';
  final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
  return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
}
