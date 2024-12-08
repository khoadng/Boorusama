// Package imports:
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';

enum BoxError {
  boxClosed,
  unknown,
}

Either<BoxError, Iterable<E>> tryGetBoxValues<E>(Box<E> box) => Either.tryCatch(
      () => box.values,
      (error, stackTrace) =>
          error is HiveError ? BoxError.boxClosed : BoxError.unknown,
    );
