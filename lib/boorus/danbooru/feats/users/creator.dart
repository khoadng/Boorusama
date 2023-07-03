// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'user.dart';
import 'user_level.dart';

class Creator extends Equatable {
  const Creator({
    required this.id,
    required this.name,
    required this.level,
  });

  factory Creator.fromUser(User user) => Creator(
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
