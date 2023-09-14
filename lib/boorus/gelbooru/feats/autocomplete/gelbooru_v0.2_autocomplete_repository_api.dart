// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_v0.2_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/string.dart';
import 'gelbooru_v0.2_autocomplete_dto.dart';
import 'rule34xxx_autocomplete_repository_api.dart';

class GelbooruV0dot2AutocompleteRepositoryApi
    implements AutocompleteRepository {
  GelbooruV0dot2AutocompleteRepositoryApi(this.api);

  final GelbooruV0dot2Api api;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) => api
      .autocomplete(null, null, query)
      .then(_parseAutocomplete)
      .then(_mapDtoToAutocomplete);
}

List<GelbooruV0Dot2AutocompleteDto> _parseAutocomplete(
    HttpResponse<dynamic> value) {
  final dtos = <GelbooruV0Dot2AutocompleteDto>[];
  final json = jsonDecode(value.response.data);

  for (final item in json) {
    dtos.add(GelbooruV0Dot2AutocompleteDto.fromJson(item));
  }

  return dtos;
}

List<AutocompleteData> _mapDtoToAutocomplete(
  List<GelbooruV0Dot2AutocompleteDto> dtos,
) =>
    dtos
        .map((e) {
          try {
            final (count, label) = extractDataFromTagLabel(e.label!);

            return AutocompleteData(
              type: 'tag',
              label: label.replaceUnderscoreWithSpace(),
              value: e.value!,
              postCount: count,
            );
          } catch (err) {
            // ignore: avoid_print
            print("can't parse ${e.label}");

            return AutocompleteData.empty;
          }
        })
        .where((e) => e != AutocompleteData.empty)
        .toList();
