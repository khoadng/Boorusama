// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/danbooru/feats/autocomplete/autocomplete_dto.dart';
import 'package:boorusama/foundation/http/http.dart';

List<AutocompleteDto> parseAutocomplete(HttpResponse<dynamic> value) =>
    parseResponse(
      value: value,
      converter: (data) => AutocompleteDto.fromJson(data),
    );

List<AutocompleteData> mapDtoToAutocomplete(List<AutocompleteDto> dtos) => dtos
    .map((e) {
      try {
        if (AutocompleteData.isTagType(e.type)) {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: e.category?.toString(),
            postCount: e.postCount,
            antecedent: e.antecedent,
          );
        } else if (e.type == AutocompleteData.pool) {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            category: e.category,
            postCount: e.postCount,
          );
        } else if (e.type == AutocompleteData.user) {
          return AutocompleteData(
            type: e.type,
            label: e.label!,
            value: e.value!,
            level: e.level,
          );
        } else {
          return AutocompleteData(label: e.label!, value: e.value!);
        }
      } catch (err) {
        // ignore: avoid_print
        print("can't parse ${e.label}");

        return AutocompleteData.empty;
      }
    })
    .where((e) => e != AutocompleteData.empty)
    .toList();

class AutocompleteRepositoryApi implements AutocompleteRepository {
  const AutocompleteRepositoryApi({
    required this.api,
  });

  final DanbooruApi api;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) => api
      .autocomplete(
        query,
        'tag_query',
        20,
      )
      .then(parseAutocomplete)
      .then(mapDtoToAutocomplete)
      .catchError((_) => <AutocompleteData>[]);
}
