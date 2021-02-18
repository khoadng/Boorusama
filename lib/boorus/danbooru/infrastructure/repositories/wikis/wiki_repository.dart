// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

final wikiProvider =
    Provider<IWikiRepository>((ref) => WikiRepository(ref.watch(apiProvider)));

class WikiRepository implements IWikiRepository {
  final IApi _api;

  WikiRepository(this._api);

  @override
  Future<Wiki> getWikiFor(
    String title, {
    CancelToken cancelToken,
  }) async {
    try {
      final value = await _api.getWiki(title);

      try {
        final dto = WikiDto.fromJson(value.response.data);
        final wiki = dto.toEntity();

        return wiki;
      } catch (e) {
        print("Cant parse $title");
        return Wiki.empty();
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return Wiki.empty();
      } else if (e.response.statusCode == 404) {
        throw NoRecordFound("That record was not found");
      } else {
        throw Exception("Failed to get wiki for $title");
      }
    }
  }
}

class NoRecordFound implements Exception {
  NoRecordFound(this.message);

  final String message;
}
