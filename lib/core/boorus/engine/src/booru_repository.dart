// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../autocompletes/autocompletes.dart';
import '../../../blacklists/blacklist.dart';
import '../../../configs/config.dart';
import '../../../configs/create.dart';
import '../../../downloads/filename.dart';
import '../../../downloads/urls.dart';
import '../../../notes/notes.dart';
import '../../../posts/count/count.dart';
import '../../../posts/favorites/providers.dart';
import '../../../posts/listing/list.dart';
import '../../../posts/post/post.dart';
import '../../../search/queries/query.dart';
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
}
