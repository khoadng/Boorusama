/// This file is used to export all the functional programming libraries used in
/// the project. It also exports the `FpState` type alias, which is used to
/// avoid conflicts with the `State` class from the Flutter SDK.

// Package imports:
import 'package:fpdart/fpdart.dart' as fpdart show State;

// The `fpdart` library is used to create functional programming constructs.
export 'package:fpdart/fpdart.dart' hide State, Tuple2;
export 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Predicate;

// In project exports:
export 'package:boorusama/utils/fp/file.dart';
export 'package:boorusama/utils/fp/hive.dart';
export 'package:boorusama/utils/fp/url.dart';

/// A type alias for the `State` class from the `fpdart` library.
typedef FpState<S, A> = fpdart.State<S, A>;
