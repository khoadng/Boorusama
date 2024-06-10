/// This file is used to export all the functional programming libraries used in
/// the project. It also exports the `FpState` type alias, which is used to
/// avoid conflicts with the `State` class from the Flutter SDK.
library;

// Package imports:
import 'package:fpdart/fpdart.dart' as fpdart show State, Option, Either, Task;

// The `fpdart` library is used to create functional programming constructs.
export 'package:fpdart/fpdart.dart' hide State, Task;
export 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Predicate;

// In project exports:
export 'package:boorusama/utils/fp/file.dart';
export 'package:boorusama/utils/fp/hive.dart';
export 'package:boorusama/utils/fp/url.dart';
export 'package:boorusama/utils/fp/json.dart';
export 'package:boorusama/utils/fp_utils.dart';

/// A type alias for the `State` class from the `fpdart` library.
typedef FpState<S, A> = fpdart.State<S, A>;
typedef FpTask<A> = fpdart.Task<A>;

extension FpdartOnNullable<T> on T? {
  fpdart.Option<T> toOption() => fpdart.Option.fromNullable(this);

  fpdart.Either<L, T> toEither<L>(L Function() onNull) =>
      fpdart.Either.fromNullable(this, onNull);
}
