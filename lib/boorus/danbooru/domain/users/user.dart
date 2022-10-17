// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'user_level.dart';

@immutable
class User extends Equatable {
  const User({
    required this.id,
    required this.level,
    required this.name,
    required this.blacklistedTags,
  });

  factory User.placeholder() => const User(
        id: 0,
        level: UserLevel.member,
        name: 'User',
        blacklistedTags: [],
      );

  final UserId id;
  final UserLevel level;
  final Username name;
  final List<String> blacklistedTags;

  @override
  List<Object?> get props => [id, level, name, blacklistedTags];
}

typedef UserId = int;
typedef Username = String;

List<String> tagStringToListTagString(String str) => str.split('\n');
