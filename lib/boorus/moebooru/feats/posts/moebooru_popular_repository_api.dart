// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../core/configs/config.dart';
import '../../../../core/foundation/http.dart';
import '../../../../core/posts/post/post.dart';
import 'posts.dart';

class MoebooruPopularRepositoryApi implements MoebooruPopularRepository {
  MoebooruPopularRepositoryApi(
    this.client,
    this.booruConfig,
  );

  final MoebooruClient client;
  final BooruConfigAuth booruConfig;

  @override
  PostsOrError getPopularPostsByDay(DateTime dateTime) =>
      TaskEither.Do(($) async {
        final data = await $(
          tryFetchRemoteData(
            fetcher: () => client.getPopularPostsByDay(date: dateTime),
          ),
        );

        return data.map(postDtoToPostNoMetadata).toList().toResult();
      });

  @override
  PostsOrError getPopularPostsByMonth(DateTime dateTime) =>
      TaskEither.Do(($) async {
        final data = await $(
          tryFetchRemoteData(
            fetcher: () => client.getPopularPostsByMonth(date: dateTime),
          ),
        );

        return data.map(postDtoToPostNoMetadata).toList().toResult();
      });

  @override
  PostsOrError getPopularPostsByWeek(DateTime dateTime) =>
      TaskEither.Do(($) async {
        final data = await $(
          tryFetchRemoteData(
            fetcher: () => client.getPopularPostsByWeek(date: dateTime),
          ),
        );

        return data.map(postDtoToPostNoMetadata).toList().toResult();
      });

  @override
  PostsOrError getPopularPostsRecent(MoebooruTimePeriod period) =>
      TaskEither.Do(($) async {
        final data = await $(
          tryFetchRemoteData(
            fetcher: () => client.getPopularPostsRecent(
              period: switch (period) {
                MoebooruTimePeriod.day => TimePeriod.day,
                MoebooruTimePeriod.week => TimePeriod.week,
                MoebooruTimePeriod.month => TimePeriod.month,
                MoebooruTimePeriod.year => TimePeriod.year,
              },
            ),
          ),
        );

        return data.map(postDtoToPostNoMetadata).toList().toResult();
      });
}
