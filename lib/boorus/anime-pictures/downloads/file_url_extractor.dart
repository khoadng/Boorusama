// Package imports:
import 'package:booru_clients/anime_pictures.dart';

// Project imports:
import '../../../core/downloads/urls/types.dart';
import '../../../core/posts/post/types.dart';
import '../../../foundation/caching.dart';

class AnimePicturesDownloadFileUrlExtractor
    with SimpleCacheMixin<DownloadUrlData>
    implements DownloadFileUrlExtractor {
  AnimePicturesDownloadFileUrlExtractor({
    required this.client,
  });

  final AnimePicturesClient client;

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) => tryGet(
    post.id.toString(),
    orElse: () async {
      final data = await client.getDownloadUrl(post.id);

      if (data == null) {
        return null;
      }

      return DownloadUrlData(
        url: data.url,
        cookie: data.cookie,
      );
    },
  );

  @override
  final Cache<DownloadUrlData> cache = Cache(
    maxCapacity: 10,
    staleDuration: const Duration(minutes: 5),
  );
}
