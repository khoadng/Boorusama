// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/moebooru/domain/moebooru_popular_repository.dart';
import 'package:boorusama/boorus/moebooru/domain/moebooru_post.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'moebooru_post_repository_api.dart';
import 'post_dto.dart';

List<MoebooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

class MoebooruPopularRepositoryApi implements MoebooruPopularRepository {
  final MoebooruApi _api;
  final BlacklistedTagRepository _blacklistedTagRepository;
  final CurrentBooruConfigRepository _currentBooruConfigRepository;

  MoebooruPopularRepositoryApi(
    this._api,
    this._blacklistedTagRepository,
    this._currentBooruConfigRepository,
  );

  @override
  Future<List<Post>> getPopularPostsByDay(DateTime dateTime) async {
    final config = await _currentBooruConfigRepository.get();
    final blacklist = await _blacklistedTagRepository.getBlacklist();
    final blacklistedTags = blacklist.map((tag) => tag.name).toSet();

    return _api
        .getPopularPostsByDay(
          config?.login,
          config?.apiKey,
          dateTime.day,
          dateTime.month,
          dateTime.year,
        )
        .then(parsePost)
        .then((posts) => posts
            .where((post) =>
                !blacklistedTags.intersection(post.tags.toSet()).isNotEmpty)
            .toList());
  }

  @override
  Future<List<Post>> getPopularPostsByMonth(DateTime dateTime) async {
    final config = await _currentBooruConfigRepository.get();
    final blacklist = await _blacklistedTagRepository.getBlacklist();
    final blacklistedTags = blacklist.map((tag) => tag.name).toSet();

    return _api
        .getPopularPostsByMonth(
          config?.login,
          config?.apiKey,
          dateTime.month,
          dateTime.year,
        )
        .then(parsePost)
        .then((posts) => posts
            .where((post) =>
                !blacklistedTags.intersection(post.tags.toSet()).isNotEmpty)
            .toList());
  }

  @override
  Future<List<Post>> getPopularPostsByWeek(DateTime dateTime) async {
    final config = await _currentBooruConfigRepository.get();
    final blacklist = await _blacklistedTagRepository.getBlacklist();
    final blacklistedTags = blacklist.map((tag) => tag.name).toSet();

    return _api
        .getPopularPostsByWeek(
          config?.login,
          config?.apiKey,
          dateTime.day,
          dateTime.month,
          dateTime.year,
        )
        .then(parsePost)
        .then((posts) => posts
            .where((post) =>
                !blacklistedTags.intersection(post.tags.toSet()).isNotEmpty)
            .toList());
  }

  @override
  Future<List<Post>> getPopularPostsRecent(MoebooruTimePeriod period) async {
    return [];
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
