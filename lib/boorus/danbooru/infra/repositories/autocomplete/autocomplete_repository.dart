// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/core/infra/http_parser.dart';

import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart'
    hide PoolCategory;

bool _isTagType(String? type) => [
      'tag',
      'tag-alias',
      'tag-abbreviation',
      'tag-other-name',
      'tag-autocorrect',
      'tag-word',
    ].contains(type);

List<AutocompleteDto> parseAutocomplete(HttpResponse<dynamic> value) =>
    parse(value: value, converter: (data) => AutocompleteDto.fromJson(data));

List<AutocompleteData> mapDtoToAutocomplete(List<AutocompleteDto> dtos) => dtos
    .map((e) {
      try {
        if (_isTagType(e.type)) {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category:
                TagAutocompleteCategory(category: intToTagCategory(e.category)),
            postCount: e.postCount!,
            antecedent: e.antecedent,
          );
        } else if (e.type == 'pool') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: PoolAutocompleteCategory(
                category: stringToPoolCategory(e.category)),
            postCount: e.postCount!,
          );
        } else if (e.type == 'user') {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            level: stringToUserLevel(e.level!),
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

  Future<List<AutocompleteData>> getAutocomplete(String query) async =>
      _accountRepository
          .get()
          .then((account) => _api.autocomplete(
                account.username,
                account.apiKey,
                query,
                'tag_query',
                10,
              ))
          .then(parseAutocomplete)
          .then(mapDtoToAutocomplete)
          .catchError((Object e) {
        throw Exception('Failed to get autocomplete for $query');
      });
}
