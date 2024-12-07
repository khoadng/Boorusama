// Project imports:
import 'package:boorusama/clients/danbooru/types/autocomplete_dto.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';

AutocompleteData convertAutocompleteDtoToData(AutocompleteDto dto) {
  try {
    if (AutocompleteData.isTagType(dto.type)) {
      return AutocompleteData(
        type: dto.type,
        label: dto.label!,
        value: dto.value!,
        category: dto.category?.toString(),
        postCount: dto.postCount,
        antecedent: dto.antecedent,
      );
    } else if (dto.type == AutocompleteData.pool) {
      return AutocompleteData(
        type: dto.type,
        label: dto.label!,
        value: dto.value!,
        category: dto.category,
        postCount: dto.postCount,
      );
    } else if (dto.type == AutocompleteData.user) {
      return AutocompleteData(
        type: dto.type,
        label: dto.label!,
        value: dto.value!,
        level: dto.level,
      );
    } else {
      return AutocompleteData(label: dto.label!, value: dto.value!);
    }
  } catch (err) {
    return AutocompleteData.empty;
  }
}
