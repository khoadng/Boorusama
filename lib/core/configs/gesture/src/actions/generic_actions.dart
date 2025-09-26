// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../downloads/downloader/providers.dart';
import '../../../../downloads/filename/providers.dart';
import '../../../../images/providers.dart';
import '../../../../posts/details_parts/widgets.dart';
import '../../../../posts/post/routes.dart';
import '../../../../posts/shares/providers.dart';
import '../../../../posts/sources/source.dart';
import '../../../../routers/routers.dart';
import '../../../../tags/show/routes.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../config/providers.dart';
import 'generic_intents.dart';

class DownloadPostAction extends Action<DownloadPostIntent> {
  @override
  Object? invoke(DownloadPostIntent intent) {
    intent.ref.download(intent.post);
    return null;
  }
}

class SharePostAction extends Action<SharePostIntent> {
  @override
  Object? invoke(SharePostIntent intent) {
    final ref = intent.ref;
    ref
        .read(shareProvider)
        .sharePost(
          intent.post,
          ref.readConfigAuth,
          context: ref.context,
          configViewer: ref.readConfigViewer,
          download: ref.readConfigDownload,
          filenameBuilder: ref.read(
            downloadFilenameBuilderProvider(ref.readConfigAuth),
          ),
          imageCacheManager: ref.read(defaultImageCacheManagerProvider),
        );
    return null;
  }
}

class BookmarkPostAction extends Action<BookmarkPostIntent> {
  @override
  Object? invoke(BookmarkPostIntent intent) {
    intent.ref.toggleBookmark(intent.post);
    return null;
  }
}

class ViewPostTagsAction extends Action<ViewPostTagsIntent> {
  @override
  Object? invoke(ViewPostTagsIntent intent) {
    final ref = intent.ref;
    goToShowTaglistPage(
      ref,
      intent.post,
      auth: ref.readConfigAuth,
    );
    return null;
  }
}

class ViewPostOriginalAction extends Action<ViewPostOriginalIntent> {
  @override
  Object? invoke(ViewPostOriginalIntent intent) {
    goToOriginalImagePage(intent.ref, intent.post);
    return null;
  }
}

class OpenPostSourceAction extends Action<OpenPostSourceIntent> {
  OpenPostSourceAction();

  @override
  Object? invoke(OpenPostSourceIntent intent) {
    intent.post.source.whenWeb(
      (source) => launchExternalUrlString(source.url),
      () => false,
    );
    return null;
  }
}

class ViewPostArtistAction extends Action<ViewPostArtistIntent> {
  @override
  Object? invoke(ViewPostArtistIntent intent) {
    // Get the first artist tag from the post
    final artist =
        intent.post.artistTags != null && intent.post.artistTags!.isNotEmpty
        ? chooseArtistTag(intent.post.artistTags!)
        : null;

    if (artist != null) {
      goToArtistPage(intent.ref, artist);
    }

    return null;
  }
}
