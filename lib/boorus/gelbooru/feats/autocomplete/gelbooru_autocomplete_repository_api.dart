// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'gelbooru_autocomplete_dto.dart';

List<GelbooruAutocompleteDto> _parseAutocomplete(HttpResponse<dynamic> value) =>
    parseResponse(
      value: value,
      converter: (data) => GelbooruAutocompleteDto.fromJson(data),
    );

List<AutocompleteData> _mapDtoToAutocomplete(
  List<GelbooruAutocompleteDto> dtos,
) =>
    dtos
        .map((e) {
          try {
            return AutocompleteData.isTagType(e.type)
                ? AutocompleteData(
                    type: e.type,
                    label: e.label?.replaceUnderscoreWithSpace() ?? '<empty>',
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
      .autocomplete(null, null, 'autocomplete2', 'tag_query', 20, query)
      .then(_parseAutocomplete)
      .then(_mapDtoToAutocomplete);
}
