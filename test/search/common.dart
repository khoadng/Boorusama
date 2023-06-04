// Project imports:
import 'package:boorusama/boorus/core/feat/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/core/feat/search/search.dart';
import 'package:boorusama/boorus/core/feat/tags/tag_info_service.dart';

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
