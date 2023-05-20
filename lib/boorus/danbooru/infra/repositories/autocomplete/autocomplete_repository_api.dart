// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<AutocompleteDto> parseAutocomplete(HttpResponse<dynamic> value) =>
    parse(value: value, converter: (data) => AutocompleteDto.fromJson(data));

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
    required DanbooruApi api,
    required this.booruConfig,
  }) : _api = api;

  final DanbooruApi _api;
  final BooruConfig booruConfig;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) async => _api
      .autocomplete(
        booruConfig.login,
        booruConfig.apiKey,
        query,
        'tag_query',
        10,
      )
      .then(parseAutocomplete)
      .then(mapDtoToAutocomplete)
      .catchError((_) => <AutocompleteData>[]);
}
