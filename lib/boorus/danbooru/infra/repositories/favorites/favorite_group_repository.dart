// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/core/infra/http_parser.dart';

const favoriteGroupApiParams =
    'id,name,post_ids,created_at,updated_at,is_public,creator';

List<FavoriteGroup> parseFavoriteGroups(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => FavoriteGroupDto.fromJson(item),
    ).map(favoriteGroupDtoToFavoriteGroup).toList();

class FavoriteGroupRepositoryApi implements FavoriteGroupRepository {
  const FavoriteGroupRepositoryApi({
    required this.api,
    required this.accountRepository,
  });

  final Api api;
  final AccountRepository accountRepository;

  @override
  Future<List<FavoriteGroup>> getFavoriteGroups({
    String? name,
    int? page,
  }) =>
      accountRepository
          .get()
          .then(
            (account) => api.getFavoriteGroups(
              account.username,
              account.apiKey,
              namePattern: name,
              page: page,
              only: favoriteGroupApiParams,
              limit: 50,
            ),
          )
          .then(parseFavoriteGroups);

  @override
  Future<List<FavoriteGroup>> getFavoriteGroupsByCreatorName({
    required String name,
    int? page,
  }) =>
      accountRepository
          .get()
          .then(
            (account) => api.getFavoriteGroups(
              account.username,
              account.apiKey,
              page: page,
              creatorName: name,
              only: favoriteGroupApiParams,
              limit: 50,
            ),
          )
          .then(parseFavoriteGroups);
}
