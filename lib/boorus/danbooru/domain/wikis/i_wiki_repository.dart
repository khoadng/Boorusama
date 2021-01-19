import 'package:boorusama/boorus/danbooru/domain/wikis/wiki.dart';

abstract class IWikiRepository {
  Future<Wiki> getWikiFor(String title);
}
