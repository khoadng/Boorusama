// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<Autocomplete> parseAutocomplete(HttpResponse<dynamic> value) =>
    parse(value: value, converter: (data) => Autocomplete.fromJson(data));

class AutocompleteRepository {
  const AutocompleteRepository({
    required this.api,
    required this.accountRepository,
  });

  final IApi api;
  final IAccountRepository accountRepository;

  Future<List<Autocomplete>> getAutocomplete(String query) => accountRepository
      .get()
      .then((account) => api.autocomplete(
          account.username, account.apiKey, query, 'tag_query', 10))
      .then(parseAutocomplete)
      .catchError((Object e) =>
          throw Exception('Failed to get autocomplete for $query'));
}
