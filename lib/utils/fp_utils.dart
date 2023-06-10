// Project imports:
import 'package:boorusama/functional.dart';

Either<E, T> validateSequentiallyUntilError<T, E>(
  T value,
  List<Either<E, T> Function(T value)> validations,
) {
  for (final validation in validations) {
    final result = validation(value);
    if (result.isLeft()) return result;
  }
  return right(value);
}
