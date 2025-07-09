// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../blacklists/blacklist.dart';
import '../../../blacklists/providers.dart';
import '../../../comments/providers.dart';
import '../../../comments/types.dart';
import '../../../configs/config.dart';
import '../../../configs/create/create.dart';
import '../../../downloads/urls/providers.dart';
import '../../../downloads/urls/types.dart';
import '../../../notes/notes.dart';
import '../../../posts/count/count.dart';
import '../../../posts/favorites/providers.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/listing/list.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/post/post.dart';
import '../../../search/queries/tag_query_composer.dart';
import '../../../tags/autocompletes/autocomplete_repository.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/providers.dart';
import '../../../tags/tag/tag.dart';
import 'booru_repository.dart';

abstract class BooruRepositoryDefault implements BooruRepository {
  const BooruRepositoryDefault();

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config);

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return EmptyBooruSpecificBlacklistTagRefRepository(ref);
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return EmptyFavoriteRepository();
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator() {
    return const DefaultGridThumbnailUrlGenerator();
  }

  @override
  ImageUrlResolver imageUrlResolver() {
    return const DefaultImageUrlResolver();
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(emptyNoteRepoProvider);
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config);

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return null;
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config);

  @override
  Ref<Object?> get ref;

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config);

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(emptyTagRepoProvider);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return DefaultTagQueryComposer(config: config);
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const DefaultTagColorGenerator();
  }

  @override
  TextMatcher? queryMatcher(BooruConfigAuth config) {
    return null;
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return TagExtractorBuilder(
      sorter: TagSorter.defaults(),
      fetcher: (post, options) => TagExtractor.extractTagsFromGenericPost(post),
    );
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(emptyCommentRepoProvider);
  }
}
