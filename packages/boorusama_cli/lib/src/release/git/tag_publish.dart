import '../../io/process_runner.dart';

abstract interface class ReleaseTagRepository {
  Future<String?> currentHead();

  Future<String?> localTagCommit(String tag);

  Future<String?> remoteTagCommit(String tag);

  Future<void> pushTag(String tag);
}

final class ReleaseTagPublishStatusService {
  const ReleaseTagPublishStatusService(this.repository);

  final ReleaseTagRepository repository;

  Future<bool> isDone({
    required String tag,
    required bool pushTag,
  }) async {
    final head = await repository.currentHead();
    if (head == null) return false;

    final localTagCommit = await repository.localTagCommit(tag);
    final remoteTagCommit = await repository.remoteTagCommit(tag);

    if (localTagCommit != null && localTagCommit != head) {
      throw ProcessFailure(
        'Local tag $tag points to $localTagCommit, not current HEAD $head.',
      );
    }
    if (remoteTagCommit != null && remoteTagCommit != head) {
      throw ProcessFailure(
        'Remote tag $tag points to $remoteTagCommit, not current HEAD $head.',
      );
    }
    if (localTagCommit != null && remoteTagCommit == null && pushTag) {
      await repository.pushTag(tag);
      return true;
    }

    return localTagCommit != null && (!pushTag || remoteTagCommit != null);
  }
}
