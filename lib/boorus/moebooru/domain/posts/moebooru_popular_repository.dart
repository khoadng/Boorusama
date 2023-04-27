// Project imports:
import 'package:boorusama/core/domain/posts.dart';

enum MoebooruTimePeriod { day, week, month, year }

abstract class MoebooruPopularRepository {
  Future<List<Post>> getPopularPostsRecent(MoebooruTimePeriod period);
  Future<List<Post>> getPopularPostsByDay(DateTime dateTime);
  Future<List<Post>> getPopularPostsByWeek(DateTime dateTime);
  Future<List<Post>> getPopularPostsByMonth(DateTime dateTime);
}
