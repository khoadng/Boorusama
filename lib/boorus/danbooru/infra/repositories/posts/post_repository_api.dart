// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/utils.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/functional.dart';
import 'common.dart';
import 'utils.dart';

List<DanbooruPost> Function(
  HttpResponse<dynamic> value,
) parsePostWithOptions({
  required bool includeInvalid,
  required ImageSourceComposer<PostDto> urlComposer,
}) =>
    (value) => includeInvalid
        ? parse(
            value: value,
            converter: (item) => PostDto.fromJson(item),
          ).map((e) => postDtoToPost(e, urlComposer)).toList()
        : parsePost(value, urlComposer);

class PostRepositoryApi implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    CurrentBooruConfigRepository currentBooruConfigRepository,
    this.urlComposer,
  )   : _api = api,
        _currentUserBooruRepository = currentBooruConfigRepository;

  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final DanbooruApi _api;
  final ImageSourceComposer<PostDto> urlComposer;

  static const int _limit = 60;

  // convert a BooruConfig and an orignal tag list to List<String>
  List<String> getTags(BooruConfig booruConfig, String tags) {
    final ratingTag = booruFilterConfigToDanbooruTag(booruConfig.ratingFilter);
    final deletedStatusTag = booruConfigDeletedBehaviorToDanbooruTag(
      booruConfig.deletedItemBehavior,
    );
    return [
      ...splitTag(tags),
      if (ratingTag != null) ratingTag,
      if (deletedStatusTag != null) deletedStatusTag,
    ];
  }

  // parse HttpResponse<dynamic> to List<DanbooruPost>
  Either<BooruError, List<DanbooruPost>> parseData(
    HttpResponse<dynamic> response,
    bool includeInvalid,
  ) =>
      Either.tryCatch(
        () => parsePostWithOptions(
          includeInvalid: includeInvalid,
          urlComposer: urlComposer,
        ).call(response),
        (error, stackTrace) => BooruError(
          error: AppError(type: AppErrorType.failedToParseJSON),
        ),
      );

  @override
  DanbooruPostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  }) =>
      getBooruConfigFrom(_currentUserBooruRepository)
          .flatMap(
            (booruConfig) => getData(
              fetcher: () => _api.getPosts(
                booruConfig.login,
                booruConfig.apiKey,
                page,
                getTags(booruConfig, tags).join(' '),
                limit ?? _limit,
              ),
            ),
          )
          .flatMap((response) => TaskEither.fromEither(parseData(
                response,
                includeInvalid ?? false,
              )));

  @override
  DanbooruPostsOrError getPostsFromIds(List<int> ids) => getPosts(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );

  @override
  Future<List<Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      getPosts(
        tags,
        page,
        limit: limit,
        includeInvalid: true,
      ).run().then((value) => value.fold(
            (l) => [],
            (r) => r,
          ));
}
