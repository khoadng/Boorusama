// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/e621/types/types.dart';
import 'package:boorusama/string.dart';

class E621AutocompleteRepository implements AutocompleteRepository {
  E621AutocompleteRepository(
    this.client,
  );

  final E621Client client;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) =>
      client.getAutocomplete(query: query).then(
          (value) => value.map(e621AutocompleteDtoToAutocompleteData).toList());
}

AutocompleteData e621AutocompleteDtoToAutocompleteData(
  AutocompleteDto dto,
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
