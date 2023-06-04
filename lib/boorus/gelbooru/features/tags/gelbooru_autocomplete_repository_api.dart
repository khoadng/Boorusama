// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/gelbooru.dart';
import 'package:boorusama/boorus/core/autocompletes/autocompletes.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'autocomplete_dto.dart';

List<AutocompleteDto> parseAutocomplete(HttpResponse<dynamic> value) =>
    parse(value: value, converter: (data) => AutocompleteDto.fromJson(data));

List<AutocompleteData> mapDtoToAutocomplete(List<AutocompleteDto> dtos) => dtos
    .map((e) {
      try {
        return AutocompleteData.isTagType(e.type)
            ? AutocompleteData(
                type: e.type,
                label: e.label!,
                value: e.value!,
                category: e.category?.toString(),
                postCount: e.postCount,
              )
            : AutocompleteData(label: e.label!, value: e.value!);
      } catch (err) {
        // ignore: avoid_print
        print("can't parse ${e.label}");

        return AutocompleteData.empty;
      }
    })
    .where((e) => e != AutocompleteData.empty)
    .toList();

class GelbooruAutocompleteRepositoryApi implements AutocompleteRepository {
  GelbooruAutocompleteRepositoryApi(this.api);

  final GelbooruApi api;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) => api
      .autocomplete(null, null, 'autocomplete2', 'tag_query', 10, query)
      .then(parseAutocomplete)
      .then(mapDtoToAutocomplete);
}
