// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/moebooru/moebooru_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import 'moebooru_post_repository_api.dart';

List<MoebooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parseResponse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

class MoebooruPopularRepositoryApi
    with GlobalBlacklistedTagFilterMixin
    implements MoebooruPopularRepository {
  MoebooruPopularRepositoryApi(
    this._api,
    this.blacklistedTagRepository,
    this.booruConfig,
  );

  final MoebooruApi _api;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
  final BooruConfig booruConfig;

  @override
  PostsOrError getPopularPostsByDay(DateTime dateTime) => tryParseResponse(
        fetcher: () => _api.getPopularPostsByDay(
          booruConfig.login,
          booruConfig.apiKey,
          dateTime.day,
          dateTime.month,
          dateTime.year,
        ),
      )
          .flatMap((response) =>
              TaskEither.fromEither(Either.of(parsePost(response))))
          .flatMap(tryFilterBlacklistedTags);

  @override
  PostsOrError getPopularPostsByMonth(DateTime dateTime) => tryParseResponse(
          fetcher: () => _api.getPopularPostsByMonth(
                booruConfig.login,
                booruConfig.apiKey,
                dateTime.month,
                dateTime.year,
              ))
      .flatMap(
          (response) => TaskEither.fromEither(Either.of(parsePost(response))))
      .flatMap(tryFilterBlacklistedTags);

  @override
  PostsOrError getPopularPostsByWeek(DateTime dateTime) => tryParseResponse(
          fetcher: () => _api.getPopularPostsByWeek(
                booruConfig.login,
                booruConfig.apiKey,
                dateTime.day,
                dateTime.month,
                dateTime.year,
              ))
      .flatMap(
          (response) => TaskEither.fromEither(Either.of(parsePost(response))))
      .flatMap(tryFilterBlacklistedTags);

  @override
  PostsOrError getPopularPostsRecent(MoebooruTimePeriod period) =>
      tryParseResponse(
              fetcher: () => _api.getPopularPostsRecent(
                    booruConfig.login,
                    booruConfig.apiKey,
                    moebooruTimePeriodToString(period),
                  ))
          .flatMap((response) =>
              TaskEither.fromEither(Either.of(parsePost(response))))
          .flatMap(tryFilterBlacklistedTags);
}

String moebooruTimePeriodToString(MoebooruTimePeriod period) =>
    switch (period) {
      MoebooruTimePeriod.day => '1d',
      MoebooruTimePeriod.week => '1w',
      MoebooruTimePeriod.month => '1m',
      MoebooruTimePeriod.year => '1y'
    };
