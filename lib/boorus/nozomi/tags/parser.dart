// Package imports:
import 'package:booru_clients/nozomi.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';

AutocompleteData autocompleteDtoToAutocompleteData(
  NozomiAutocompleteDto dto,
) {
  return AutocompleteData(
    label: dto.tag.replaceAll('_', ' '),
    value: dto.tag,
    postCount: dto.postCount,
  );
}
