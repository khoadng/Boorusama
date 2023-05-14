// Package imports:
import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  const Artist({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isBanned,
    required this.groupName,
    required this.isDeleted,
    required this.otherNames,
    required this.name,
  });

  factory Artist.empty() => Artist(
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

extension ArtistX on Artist {
  bool get isEmpty => this == Artist.empty();

  Artist copyWith({
    int? id,
    String? name,
    List<String>? otherNames,
  }) =>
      Artist(
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
