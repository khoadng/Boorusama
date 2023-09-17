// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

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
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) => client
      .autocomplete(
        query: query,
      )
      .then(mapDtoToAutocomplete)
      .catchError((_) => <AutocompleteData>[]);
}
