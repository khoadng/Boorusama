// Project imports:
import '../../../../core/posts/position/types.dart';

String buildIdContinuationQuery(PaginationSnapshot snapshot) {
  final tags = snapshot.tags.trim();
  return tags.isEmpty
      ? 'id:>=${snapshot.targetId} order:id'
      : '$tags id:>=${snapshot.targetId} order:id';
}
