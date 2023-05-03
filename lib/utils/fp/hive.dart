// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/functional.dart';

enum BoxError {
  boxClosed,
  unknown,
}

Either<BoxError, Iterable<E>> tryGetBoxValues<E>(Box<E> box) => Either.tryCatch(
      () => box.values,
      (error, stackTrace) =>
          error is HiveError ? BoxError.boxClosed : BoxError.unknown,
    );
