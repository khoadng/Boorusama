// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/users/users.dart';
import 'user.dart';
import 'user_level.dart';

class Creator extends Equatable {
  const Creator({
    required this.id,
    required this.name,
    required this.level,
  });

  factory Creator.fromUser(DanbooruUser user) => Creator(
        id: user.id,
        name: user.name,
        level: user.level,
      );

  factory Creator.empty() => const Creator(
        id: -1,
        name: 'Creator',
        level: UserLevel.member,
      );

  factory Creator.fromJson(String jsonStr) {
    final jsonData = json.decode(jsonStr);
    return Creator(
      id: jsonData['id'],
      name: jsonData['name'],
      level: UserLevel.values[jsonData['level']],
    );
  }

  final CreatorId id;
  final CreatorName name;
  final UserLevel level;

  String toJson() {
    final jsonData = {
      'id': id,
      'name': name,
      'level': level.index,
    };
    return json.encode(jsonData);
  }

  @override
  List<Object?> get props => [id, name, level];
}

typedef CreatorId = int;
typedef CreatorName = String;

Creator creatorDtoToCreator(CreatorDto? d) => d != null
    ? Creator(
        id: d.id!,
        name: d.name ?? '',
        level: d.level == null ? UserLevel.member : intToUserLevel(d.level!),
      )
    : Creator.empty();

extension CreatorDtoX on Creator? {
  Color getColor(BuildContext context) {
    final creatorLevel = this?.level ?? UserLevel.member;

    return creatorLevel.toColor(context);
  }
}
