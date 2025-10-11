// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/bookmarks/src/data/bookmark_convert.dart';
import '../../core/boorus/defaults/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/posts/post/types.dart';
import '../../core/tags/autocompletes/types.dart';
import 'providers.dart';

const _bookmarkSampleData = [
  {
    'id': '12345',
    'tags': 'bookmark sample_tag amazing_art',
    'extension': 'jpg',
    'md5': '9cf364e77f46183e2ebd75de757488e2',
    'width': '1920',
    'height': '1080',
    'rating': 'general',
    'index': '0',
  },
];

class BookmarkBooruRepository extends BooruRepositoryDefault {
  BookmarkBooruRepository(this.ref);

  @override
  final Ref ref;

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return EmptyAutocompleteRepository();
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(bookmarkBooruRepoProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return BookmarkPostLinkGenerator();
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    return null;
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<BookmarkPost>(
      tokenHandlers: [],
      sampleData: _bookmarkSampleData,
      defaultFileNameFormat: '{id}_{tags}_{md5}.{extension}',
      defaultBulkDownloadFileNameFormat: '{id}_{md5}.{extension}',
    );
  }
}

class BookmarkPostLinkGenerator extends PostLinkGenerator<Post> {
  @override
  String getLink(Post post) {
    return 'bookmarks://post/${post.id}';
  }
}
