// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_popular_repository.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_post.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/core/application/posts/filter.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'package:boorusama/functional.dart';
import 'moebooru_post_repository_api.dart';

List<MoebooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

class MoebooruPopularRepositoryApi
    with BlacklistedTagFilterMixin, CurrentBooruConfigRepositoryMixin
    implements MoebooruPopularRepository {
  MoebooruPopularRepositoryApi(
    this._api,
    this.blacklistedTagRepository,
    this.currentBooruConfigRepository,
  );

  final MoebooruApi _api;
  @override
  final BlacklistedTagRepository blacklistedTagRepository;
  @override
  final CurrentBooruConfigRepository currentBooruConfigRepository;

  @override
  PostsOrError getPopularPostsByDay(DateTime dateTime) => tryGetBooruConfig()
      .flatMap((config) => tryParseResponse(
            fetcher: () => _api.getPopularPostsByDay(
              config.login,
              config.apiKey,
              dateTime.day,
              dateTime.month,
              dateTime.year,
            ),
          ))
      .flatMap(
          (response) => TaskEither.fromEither(Either.of(parsePost(response))))
      .flatMap(tryFilterBlacklistedTags);

  @override
  PostsOrError getPopularPostsByMonth(DateTime dateTime) => tryGetBooruConfig()
      .flatMap((config) => tryParseResponse(
          fetcher: () => _api.getPopularPostsByMonth(
                config.login,
                config.apiKey,
                dateTime.month,
                dateTime.year,
              )))
      .flatMap(
          (response) => TaskEither.fromEither(Either.of(parsePost(response))))
      .flatMap(tryFilterBlacklistedTags);

  @override
  PostsOrError getPopularPostsByWeek(DateTime dateTime) => tryGetBooruConfig()
      .flatMap((config) => tryParseResponse(
          fetcher: () => _api.getPopularPostsByWeek(
                config.login,
                config.apiKey,
                dateTime.day,
                dateTime.month,
                dateTime.year,
              )))
      .flatMap(
          (response) => TaskEither.fromEither(Either.of(parsePost(response))))
      .flatMap(tryFilterBlacklistedTags);

  @override
  PostsOrError getPopularPostsRecent(MoebooruTimePeriod period) {
    return TaskEither.of([]);
    // final config = await _currentBooruConfigRepository.get();
    // final blacklist = await _blacklistedTagRepository.getBlacklist();
    // final blacklistedTags = blacklist.map((tag) => tag.name).toSet();

    // return _api
    //     .getPopularPostsRecent(
    //       config?.login,
    //       config?.apiKey,
    //       moebooruTimePeriodToString(period),
    //     )
    //     .then(parsePost)
    //     .then((posts) => posts
    //         .where((post) =>
    //             !blacklistedTags.intersection(post.tags.toSet()).isNotEmpty)
    //         .toList());
  }
}

String moebooruTimePeriodToString(MoebooruTimePeriod period) {
  switch (period) {
    case MoebooruTimePeriod.day:
      return '1d';
    case MoebooruTimePeriod.week:
      return '1w';
    case MoebooruTimePeriod.month:
      return '1m';
    case MoebooruTimePeriod.year:
      return '1y';
  }
}
