import 'package:boorusama/domain/wikis/wiki.dart';

abstract class IWikiRepository {
  Future<Wiki> getWikiFor(String title);
}
