// Package imports:
import 'package:equatable/equatable.dart';

class DmailId extends Equatable {
  const DmailId._(this.value);

  const DmailId.invalid() : value = -1;

  static DmailId? tryParse(dynamic value) => switch (value) {
    final int i => DmailId._(i),
    final String s => switch (int.tryParse(s)) {
      final int i => DmailId._(i),
      _ => null,
    },
    _ => null,
  };

  static DmailId? tryParseFromPathParams(Map<String, String> params) =>
      tryParse(params['id']);

  final int value;

  String toPathSegment() => value.toString();

  @override
  List<Object?> get props => [value];
}
