// Project imports:
import 'package:boorusama/core/posts/position/types.dart';

class MockPageFinderRepository implements PageFinderRepository {
  MockPageFinderRepository({
    required this.totalItems,
    required this.itemsPerPage,
  });

  final int totalItems;
  final int itemsPerPage;
  final List<PageFinderQuery> requestLog = [];

  @override
  Future<PageFinderResult> fetchItems(PageFinderQuery query) async {
    requestLog.add(query);

    if (query.page < 1) {
      return PageFinderSuccess(items: const []);
    }

    final startIndex = (query.page - 1) * query.limit;
    final endIndex = (startIndex + query.limit).clamp(0, totalItems);

    if (startIndex >= totalItems) {
      return PageFinderSuccess(items: const []);
    }

    final items = List.generate(
      endIndex - startIndex,
      (i) => PageFinderTarget(id: totalItems - startIndex - i),
    );

    return PageFinderSuccess(items: items);
  }
}
