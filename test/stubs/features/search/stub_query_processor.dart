import 'package:boorusama/boorus/danbooru/presentation/features/search/services/query_processor.dart';
import 'package:hooks_riverpod/all.dart';

final stubQueryProcessorProvider = Provider<QueryProcessor>((ref) {
  return StubQueryProcessor();
});

class StubQueryProcessor implements QueryProcessor {
  @override
  String process(
      String currentQuery, String lastQuery, List<String> completedQueries) {
    return currentQuery;
  }
}
