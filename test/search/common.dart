// Project imports:
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/domain/autocompletes/autocomplete.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';

TagSearchState tagSearchStateEmpty() => const TagSearchState(
      query: '',
      selectedTags: [],
      suggestionTags: [],
      metaTagMatches: [],
      isDone: false,
      operator: FilterOperator.none,
    );

TagSearchItem tagSearchItemFromString(String value) => TagSearchItem.fromString(
      value,
      const TagInfo(
        metatags: [],
        defaultBlacklistedTags: [],
        r18Tags: [],
      ),
    );

AutocompleteData autocompleteData([String? value]) => value != null
    ? AutocompleteData(label: value, value: value)
    : AutocompleteData.empty;
