// Project imports:
import '../../../../videos/cache/types.dart';
import '../../../../videos/player/types.dart';
import '../../../post/post.dart';

CacheDelayCallback createVideoCacheDelayCallback<T extends Post>(T post) =>
    (url, state) => calculateCacheDelay(post.duration, post.fileSize);
