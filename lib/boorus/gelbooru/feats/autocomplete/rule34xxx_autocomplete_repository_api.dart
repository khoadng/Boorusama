// Package imports:

// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/rule34xxx/rule34xxx_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/string.dart';
import 'rule34xxx_autocomplete_dto.dart';

(int count, String label) extractDataFromTagLabel(String input) {
  // extract data from tag label e.g abc (40) -> (40, abc)
  final match = RegExp(r'(.*) \((\d+)\)').firstMatch(input);

  if (match == null) {
    throw Exception('can\'t parse tag label');
  }

  final count = int.parse(match.group(2)!);
  final label = match.group(1)!;

  return (count, label);
}

List<Rule34xxxAutocompleteDto> _parseAutocomplete(HttpResponse<dynamic> value) {
  final dtos = <Rule34xxxAutocompleteDto>[];
  final json = jsonDecode(value.response.data);

  for (final item in json) {
    dtos.add(Rule34xxxAutocompleteDto.fromJson(item));
  }

  return dtos;
}

List<AutocompleteData> _mapDtoToAutocomplete(
  List<Rule34xxxAutocompleteDto> dtos,
) =>
    dtos
        .map((e) {
          try {
            final (count, label) = extractDataFromTagLabel(e.label!);

            return AutocompleteData(
              type: 'tag',
              label: label.replaceUnderscoreWithSpace(),
              value: e.value!,
              category: stringToTagCategory(e.type!).stringify(),
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

class Rule34xxxAutocompleteRepositoryApi implements AutocompleteRepository {
  Rule34xxxAutocompleteRepositoryApi(this.api);

  final Rule34xxxApi api;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) => api
      .autocomplete(null, null, query)
      .then(_parseAutocomplete)
      .then(_mapDtoToAutocomplete);
}
