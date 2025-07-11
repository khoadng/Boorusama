// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../blacklists/blacklist.dart';
import '../../../comments/types.dart';
import '../../../configs/config.dart';
import '../../../configs/create/create.dart';
import '../../../downloads/filename/types.dart';
import '../../../downloads/urls/types.dart';
import '../../../errors/types.dart';
import '../../../notes/notes.dart';
import '../../../posts/count/count.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/listing/list.dart';
import '../../../posts/post/post.dart';
import '../../../search/queries/query.dart';
import '../../../tags/autocompletes/types.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/tag.dart';

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
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator();
  TagColorGenerator tagColorGenerator();
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config);
  TextMatcher? queryMatcher(BooruConfigAuth config);
  TagExtractor tagExtractor(BooruConfigAuth config);
  CommentRepository comment(BooruConfigAuth config);
  Dio dio(BooruConfigAuth config);
  Map<String, String> extraHttpHeaders(BooruConfigAuth config);
  AppErrorTranslator appErrorTranslator(BooruConfigAuth config);
}
