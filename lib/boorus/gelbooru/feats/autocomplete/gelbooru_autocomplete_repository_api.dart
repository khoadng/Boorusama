// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/types/types.dart';
import 'package:boorusama/string.dart';

List<AutocompleteData> _mapDtoToAutocomplete(
  List<AutocompleteDto> dtos,
) =>
    dtos
        .map((e) {
          try {
            return AutocompleteData(
              type: e.type,
              label: e.label?.replaceUnderscoreWithSpace() ?? '<empty>',
              value: e.value!,
              category: e.category?.toString(),
              postCount: e.postCount,
            );
          } catch (err) {
            // ignore: avoid_print
            print("can't parse ${e.label}");

            return AutocompleteData.empty;
          }
        })
        .where((e) => e != AutocompleteData.empty)
        .toList();

class GelbooruAutocompleteRepositoryApi implements AutocompleteRepository {
  GelbooruAutocompleteRepositoryApi(this.client);

  final GelbooruClient client;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) =>
      client.autocomplete(term: query, limit: 20).then(_mapDtoToAutocomplete);
}
