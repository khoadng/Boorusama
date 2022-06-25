// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'user_dto.dart';
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
        id: UserId(0),
        level: UserLevel.member,
        name: Username('User'),
        blacklistedTags: [],
      );

  final UserId id;
  final UserLevel level;
  final Username name;
  final List<String> blacklistedTags;

  @override
  List<Object?> get props => [id, level, name, blacklistedTags];
}

class Username extends Equatable {
  const Username(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class UserId extends Equatable {
  const UserId(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}

User userDtoToUser(
  UserDto d,
  List<String> defaultBlacklistedTags,
) {
  try {
    return User(
      id: UserId(d.id!),
      level: intToUserLevel(d.level!),
      name: Username(d.name!),
      //TODO: need to find a way to distinguish between other user and current user.
      blacklistedTags: d.blacklistedTags == null
          ? defaultBlacklistedTags
          : tagStringToListTagString(d.blacklistedTags!),
    );
  } catch (e) {
    throw Exception('fail to parse one of the required field\n $e');
  }
}

List<String> tagStringToListTagString(String str) => str.split('\n');
