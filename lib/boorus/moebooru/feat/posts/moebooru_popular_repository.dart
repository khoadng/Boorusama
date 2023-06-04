// Project imports:
import 'package:boorusama/boorus/core/feat/posts/posts.dart';

enum MoebooruTimePeriod { day, week, month, year }

abstract class MoebooruPopularRepository {
  PostsOrError getPopularPostsRecent(MoebooruTimePeriod period);
  PostsOrError getPopularPostsByDay(DateTime dateTime);
  PostsOrError getPopularPostsByWeek(DateTime dateTime);
  PostsOrError getPopularPostsByMonth(DateTime dateTime);
}
