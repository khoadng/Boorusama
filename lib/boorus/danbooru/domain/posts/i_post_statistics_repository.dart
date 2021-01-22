import 'post_statistics.dart';

abstract class IPostStatisticsRepository {
  // Non-API
  Future<PostStatistics> getPostStatistics(int id);
}
