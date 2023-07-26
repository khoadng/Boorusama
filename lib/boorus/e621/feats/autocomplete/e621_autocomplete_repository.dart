// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_repository.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/string.dart';
import 'e621_autocomplete_dto.dart';

class E621AutocompleteRepository implements AutocompleteRepository {
  E621AutocompleteRepository(this.api, this.tagRepo);

  final E621Api api;
  final E621TagRepository tagRepo;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) =>
      switch (query.length) {
        0 || 1 => Future.value(<AutocompleteData>[]),
        2 => tagRepo.getTagsWithWildcard(query).then(parseAutocompleteData),
        _ => api
            .autocomplete(query, 7)
            .then((value) => parseResponse(
                  value: value,
                  converter: (item) => E621AutocompleteDto.fromJson(item),
                ))
            .then((e) => e.map(e621AutocompleteDtoToAutocompleteData).toList())
            .catchError((_) => <AutocompleteData>[]),
      };
}

AutocompleteData e621AutocompleteDtoToAutocompleteData(
  E621AutocompleteDto dto,
) {
  return AutocompleteData(
    type: AutocompleteData.tag,
    label: dto.name?.replaceUnderscoreWithSpace() ?? '',
    value: dto.name ?? '',
    category: intToE621TagCategory(dto.category).name,
    postCount: dto.postCount,
    antecedent: dto.antecedentName,
  );
}

List<AutocompleteData> parseAutocompleteData(List<E621Tag> tags) =>
    tags.map(mapTagToAutocomplete).toList();

AutocompleteData mapTagToAutocomplete(E621Tag tag) => AutocompleteData(
      type: AutocompleteData.tag,
      label: tag.name.replaceUnderscoreWithSpace(),
      value: tag.name,
      postCount: tag.postCount,
      category: tag.category.name,
    );
