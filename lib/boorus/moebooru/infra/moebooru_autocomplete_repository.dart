// Project imports:
import 'package:boorusama/boorus/moebooru/domain/tag_summary.dart';
import 'package:boorusama/boorus/moebooru/domain/tag_summary_repository.dart';
import 'package:boorusama/core/domain/autocompletes.dart';

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
