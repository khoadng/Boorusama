import 'package:boorusama/boorus/danbooru/domain/posts/i_post_statistics_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';

import 'post_statistics_cache.dart';

class PostStatisticsCacheDecorator implements IPostStatisticsRepository {
  final IPostStatisticsRepository _postStatisticsRepository;
  final IPostStatisticsCache _postStatisticsCache;
  final String _endpoint;

  PostStatisticsCacheDecorator(this._postStatisticsRepository,
      this._postStatisticsCache, this._endpoint);

  @override
  Future<PostStatistics> getPostStatistics(int postId) async {
    final key = "$_endpoint+post_statistics+$postId";
    if (await _postStatisticsCache.isExist(key) &&
        await _postStatisticsCache.isExpired(key) == false) {
      final cache = _postStatisticsCache.get(key);
      return Future.value(cache);
    } else {
      final commentary =
          await _postStatisticsRepository.getPostStatistics(postId);
      _postStatisticsCache.put(key, commentary, Duration(seconds: 10));

      return commentary;
    }
  }
}
