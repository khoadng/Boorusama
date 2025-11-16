// Package imports:
import 'package:equatable/equatable.dart';

// We should use start using the PostId class instead of int
sealed class PostId {
  const PostId();

  static PostId from(String value) {
    if (int.tryParse(value) != null) {
      return NumericPostId(int.parse(value));
    } else {
      return StringPostId(value);
    }
  }
}

class NumericPostId extends PostId with EquatableMixin {
  const NumericPostId(this.value);

  final int value;

  @override
  String toString() => value.toString();

  @override
  List<Object?> get props => [value];
}

class StringPostId extends PostId with EquatableMixin {
  const StringPostId(this.value);

  final String value;

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}
