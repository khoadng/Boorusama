// Project imports:
import '../../../../../core/posts/post/types.dart';

sealed class E621PostStatus
    with LowercaseMatchesStatusMixin
    implements PostStatus {
  const E621PostStatus({
    required this.value,
  });

  static E621PostStatus? from({
    required bool? isPending,
    required bool? isFlagged,
    required bool? isDeleted,
  }) => switch ((isPending, isFlagged, isDeleted)) {
    (_, _, true) => const DeletedStatus(),
    (_, true, _) => const FlaggedStatus(),
    (true, _, _) => const PendingStatus(),
    _ => null,
  };

  @override
  final String value;
}

class DeletedStatus extends E621PostStatus {
  const DeletedStatus() : super(value: 'deleted');
}

class FlaggedStatus extends E621PostStatus {
  const FlaggedStatus() : super(value: 'flagged');
}

class PendingStatus extends E621PostStatus {
  const PendingStatus() : super(value: 'pending');
}
