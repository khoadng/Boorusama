// Project imports:
import '../../../../../core/posts/post/types.dart';

sealed class DanbooruPostStatus
    with LowercaseMatchesStatusMixin
    implements PostStatus {
  const DanbooruPostStatus({
    required this.value,
  });

  static DanbooruPostStatus? from({
    required bool? isPending,
    required bool? isFlagged,
    required bool? isDeleted,
    required bool? isBanned,
  }) => switch ((isPending, isFlagged, isDeleted, isBanned)) {
    (_, _, _, true) => const BannedStatus(),
    (_, _, true, _) => const DeletedStatus(),
    (_, true, _, _) => const FlaggedStatus(),
    (true, _, _, _) => const PendingStatus(),
    _ => null,
  };

  bool get isBanned => this is BannedStatus;

  @override
  final String value;
}

class BannedStatus extends DanbooruPostStatus {
  const BannedStatus() : super(value: 'banned');
}

class DeletedStatus extends DanbooruPostStatus {
  const DeletedStatus() : super(value: 'deleted');
}

class FlaggedStatus extends DanbooruPostStatus {
  const FlaggedStatus() : super(value: 'flagged');
}

class PendingStatus extends DanbooruPostStatus {
  const PendingStatus() : super(value: 'pending');
}
