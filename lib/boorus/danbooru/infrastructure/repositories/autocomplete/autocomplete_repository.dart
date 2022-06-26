// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart' as t;
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart'
    hide PoolCategory;

List<AutocompleteDto> parseAutocomplete(HttpResponse<dynamic> value) =>
    parse(value: value, converter: (data) => AutocompleteDto.fromJson(data));

List<AutocompleteData> mapDtoToAutocomplete(List<AutocompleteDto> dtos) => dtos
    .map((e) {
      try {
        if (e.type == 'tag') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: TagCategory(category: t.intToTagCategory(e.category)),
            postCount: e.postCount!,
          );
        } else if (e.type == 'tag-alias') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: TagCategory(category: t.intToTagCategory(e.category)),
            postCount: e.postCount!,
            antecedent: e.antecedent!,
          );
        } else if (e.type == 'pool') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: PoolCategory(category: stringToPoolCategory(e.category)),
            postCount: e.postCount!,
          );
        } else if (e.type == 'user') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            level: stringToUserLevel(e.level!),
          );
        } else if (e.type == 'tag-abbreviation') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: TagCategory(category: t.intToTagCategory(e.category)),
            postCount: e.postCount!,
            antecedent: e.antecedent!,
          );
        } else if (e.type == 'tag-other-name') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: TagCategory(category: t.intToTagCategory(e.category)),
            postCount: e.postCount!,
            antecedent: e.antecedent!,
          );
        } else {
          return AutocompleteData(label: e.label!, value: e.value!);
        }
      } catch (err) {
        // ignore: avoid_print
        print("can't parse ${e.label}");
        return const AutocompleteData(label: '', value: '');
      }
    })
    .where((e) => e != AutocompleteData.empty)
    .toList();

class AutocompleteRepository {
  const AutocompleteRepository({
    required Api api,
    required IAccountRepository accountRepository,
  })  : _accountRepository = accountRepository,
        _api = api;

  final Api _api;
  final IAccountRepository _accountRepository;

  Future<List<AutocompleteData>>
      getAutocomplete(String query) =>
          _accountRepository
              .get()
              .then((account) => _api.autocomplete(
                  account.username, account.apiKey, query, 'tag_query', 10))
              .then(parseAutocomplete)
              .then(mapDtoToAutocomplete)
              .catchError((Object e) =>
                  throw Exception('Failed to get autocomplete for $query'));
}
