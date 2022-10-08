// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart' as t;
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'autocomplete_http_cache.dart';

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
            category: TagCategory(category: t.intToTagCategory(e.category)),
            postCount: e.postCount!,
            antecedent: e.antecedent,
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
    required AutocompleteHttpCacher cache,
  })  : _accountRepository = accountRepository,
        _api = api,
        _cache = cache;

  final Api _api;
  final IAccountRepository _accountRepository;
  final AutocompleteHttpCacher _cache;

  Future<List<AutocompleteData>> getAutocomplete(String query) async =>
      _accountRepository
          .get()
          .then((account) async {
            if (_cache.exist(query)) {
              final cache = cacheObjectFromJson(_cache.get(query)!);
              if (cache.isFresh(DateTime.now())) {
                final data = jsonDecode(cache.value);
                return [
                  HttpResponse(
                    data,
                    Response(
                      data: data,
                      requestOptions: RequestOptions(path: ''),
                    ),
                  ),
                  false,
                ];
              }
            }

            return [
              await _api.autocomplete(
                account.username,
                account.apiKey,
                query,
                'tag_query',
                10,
              ),
              true,
            ];
          })
          .then((dynamic value) async {
            final data = value[0] as HttpResponse<dynamic>;
            final fresh = value[1] as bool;
            // only update cache if it is fresh data
            if (fresh) {
              return updateCache(_cache, query, data);
            } else {
              return data;
            }
          })
          .then(parseAutocomplete)
          .then(mapDtoToAutocomplete)
          .catchError((Object e) {
            throw Exception('Failed to get autocomplete for $query');
          });
}
