// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

class MoebooruPopularRepositoryApi implements MoebooruPopularRepository {
  MoebooruPopularRepositoryApi(
    this.client,
    this.booruConfig,
  );

  final MoebooruClient client;
  final BooruConfig booruConfig;

  @override
  PostsOrError getPopularPostsByDay(DateTime dateTime) =>
      TaskEither.Do(($) async {
        final data = await $(tryFetchRemoteData(
          fetcher: () => client.getPopularPostsByDay(date: dateTime),
        ));

        return data.map(postDtoToPostNoMetadata).toList();
      });

  @override
  PostsOrError getPopularPostsByMonth(DateTime dateTime) =>
      TaskEither.Do(($) async {
        final data = await $(tryFetchRemoteData(
          fetcher: () => client.getPopularPostsByMonth(date: dateTime),
        ));

        return data.map(postDtoToPostNoMetadata).toList();
      });

  @override
  PostsOrError getPopularPostsByWeek(DateTime dateTime) =>
      TaskEither.Do(($) async {
        final data = await $(tryFetchRemoteData(
          fetcher: () => client.getPopularPostsByWeek(date: dateTime),
        ));

        return data.map(postDtoToPostNoMetadata).toList();
      });

  @override
  PostsOrError getPopularPostsRecent(MoebooruTimePeriod period) =>
      TaskEither.Do(($) async {
        final data = await $(tryFetchRemoteData(
          fetcher: () => client.getPopularPostsRecent(
              period: switch (period) {
            MoebooruTimePeriod.day => TimePeriod.day,
            MoebooruTimePeriod.week => TimePeriod.week,
            MoebooruTimePeriod.month => TimePeriod.month,
            MoebooruTimePeriod.year => TimePeriod.year,
          }),
        ));

        return data.map(postDtoToPostNoMetadata).toList();
      });
}
