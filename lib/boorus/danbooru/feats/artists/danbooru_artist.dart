// Package imports:
import 'package:equatable/equatable.dart';

class DanbooruArtist extends Equatable {
  const DanbooruArtist({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isBanned,
    required this.groupName,
    required this.isDeleted,
    required this.otherNames,
    required this.name,
  });

  factory DanbooruArtist.empty() => DanbooruArtist(
        createdAt: DateTime(1),
        id: 0,
        name: '',
        groupName: '',
        isBanned: false,
        isDeleted: false,
        otherNames: const [],
        updatedAt: DateTime(1),
      );

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String groupName;
  final bool isBanned;
  final List<String> otherNames;
  final String name;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        groupName,
        isBanned,
        otherNames,
        name,
      ];
}

extension DanbooruArtistX on DanbooruArtist {
  bool get isEmpty => this == DanbooruArtist.empty();

  DanbooruArtist copyWith({
    int? id,
    String? name,
    List<String>? otherNames,
  }) =>
      DanbooruArtist(
        id: id ?? this.id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isBanned: isBanned,
        groupName: groupName,
        isDeleted: isDeleted,
        otherNames: otherNames ?? this.otherNames,
        name: name ?? this.name,
      );
}
