// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../blacklists/types.dart';
import '../../../comments/types.dart';
import '../../../configs/config/types.dart';
import '../../../configs/create/create.dart';
import '../../../downloads/filename/types.dart';
import '../../../downloads/urls/types.dart';
import '../../../errors/types.dart';
import '../../../notes/note/types.dart';
import '../../../posts/count/types.dart';
import '../../../posts/details/types.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/listing/types.dart';
import '../../../posts/post/types.dart';
import '../../../posts/rating/types.dart';
import '../../../search/queries/types.dart';
import '../../../tags/autocompletes/types.dart';
import '../../../tags/metatag/types.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/types.dart';
import 'booru_builder_types.dart';

abstract class BooruRepository {
  Ref get ref;

  PostCountRepository? postCount(BooruConfigSearch config);
  PostRepository<Post> post(BooruConfigSearch config);
  AutocompleteRepository autocomplete(BooruConfigAuth config);
  NoteRepository note(BooruConfigAuth config);
  TagRepository tag(BooruConfigAuth config);
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config);
  FavoriteRepository favorite(BooruConfigAuth config);
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config);
  BooruSiteValidator? siteValidator(BooruConfigAuth config);
  TagQueryComposer tagComposer(BooruConfigSearch config);
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config);
  ImageUrlResolver imageUrlResolver();
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator(BooruConfigAuth config);
  TagColorGenerator tagColorGenerator();
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config);
  TextMatcher? queryMatcher(BooruConfigAuth config);
  TagExtractor tagExtractor(BooruConfigAuth config);
  MetatagExtractor? getMetatagExtractor(BooruConfigAuth config);
  CommentRepository comment(BooruConfigAuth config);
  Dio dio(BooruConfigAuth config);
  Map<String, String> extraHttpHeaders(BooruConfigAuth config);
  AppErrorTranslator appErrorTranslator(BooruConfigAuth config);
  BooruLoginDetails loginDetails(BooruConfigAuth config);
  MediaUrlResolver mediaUrlResolver(BooruConfigAuth config);
  GranularRatingFilterer? granularRatingFilterer(BooruConfigSearch config);
  Set<Rating> getGranularRatingOptions(BooruConfigAuth config);
  bool handlePostGesture(WidgetRef ref, String? action, Post post);
  CommentExtractor commentExtractor(BooruConfigAuth config);
}
