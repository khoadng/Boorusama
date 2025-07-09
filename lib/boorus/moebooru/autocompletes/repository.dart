// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../tag_summary/types.dart';
import 'parser.dart';

class MoebooruAutocompleteRepository implements AutocompleteRepository {
  MoebooruAutocompleteRepository({
    required this.tagSummaryRepository,
  });

  final TagSummaryRepository tagSummaryRepository;
  List<AutocompleteData> _autocompleteDataList = [];

  Future<void> initialize() async {
    final tagSummaries = await tagSummaryRepository.getTagSummaries();
    _autocompleteDataList = tagSummaries
        .expand(convertTagSummaryToAutocompleteData)
        .toList();
  }

  @override
  Future<List<AutocompleteData>> getAutocomplete(
    AutocompleteQuery query,
  ) async {
    if (_autocompleteDataList.isEmpty) {
      await initialize();
    }
    final matchingAutocompleteData = _autocompleteDataList.where(
      (autocompleteData) => autocompleteData.value.toLowerCase().startsWith(
        query.text.toLowerCase(),
      ),
    );
    return matchingAutocompleteData.take(20).toList();
  }
}
