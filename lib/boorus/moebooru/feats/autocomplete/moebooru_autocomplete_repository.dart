// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'converter.dart';

class MoebooruAutocompleteRepository implements AutocompleteRepository {
  MoebooruAutocompleteRepository({
    required this.tagSummaryRepository,
  });

  final TagSummaryRepository tagSummaryRepository;
  List<AutocompleteData> _autocompleteDataList = [];

  Future<void> initialize() async {
    final tagSummaries = await tagSummaryRepository.getTagSummaries();
    _autocompleteDataList =
        tagSummaries.expand(convertTagSummaryToAutocompleteData).toList();
  }

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) async {
    if (_autocompleteDataList.isEmpty) {
      await initialize();
    }
    final matchingAutocompleteData = _autocompleteDataList.where(
        (autocompleteData) => autocompleteData.value
            .toLowerCase()
            .startsWith(query.toLowerCase()));
    return matchingAutocompleteData.take(20).toList();
  }
}
