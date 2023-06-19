// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_repository.dart';
import '../tags/e621_tag.dart';

class E621AutocompleteRepository implements AutocompleteRepository {
  E621AutocompleteRepository(this.repo);

  final E621TagRepository repo;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) =>
      repo.getTags(query).then(parseAutocompleteData);
}

List<AutocompleteData> parseAutocompleteData(List<E621Tag> tags) =>
    tags.map(mapTagToAutocomplete).toList();

AutocompleteData mapTagToAutocomplete(E621Tag tag) => AutocompleteData(
      type: 'tag',
      label: tag.name,
      value: tag.name,
      postCount: tag.postCount,
      category: tag.category.name,
    );
