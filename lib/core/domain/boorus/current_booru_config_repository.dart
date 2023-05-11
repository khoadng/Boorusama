// Project imports:
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/functional.dart';
import 'booru_config.dart';

abstract class CurrentBooruConfigRepository {
  Future<BooruConfig?> get();
}

TaskEither<BooruError, BooruConfig> tryGetBooruConfigFrom(
        CurrentBooruConfigRepository configRepository) =>
    TaskEither<BooruError, BooruConfig?>.tryCatch(
      () => configRepository.get(),
      (error, stackTrace) =>
          AppError(type: AppErrorType.failedToLoadBooruConfig),
    ).flatMap((r) => r == null
        ? TaskEither.left(
            AppError(type: AppErrorType.booruConfigNotFound),
          )
        : TaskEither.right(r));

mixin CurrentBooruConfigRepositoryMixin {
  CurrentBooruConfigRepository get currentBooruConfigRepository;

  TaskEither<BooruError, BooruConfig> tryGetBooruConfig() =>
      tryGetBooruConfigFrom(currentBooruConfigRepository);
}
