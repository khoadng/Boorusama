// Package imports:
import 'package:equatable/equatable.dart';

class BlacklistedTag extends Equatable {
  const BlacklistedTag({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
  });

  factory BlacklistedTag.fromJson(Map<String, dynamic> json) => BlacklistedTag(
    id: json['id'] as int,
    name: json['name'] as String,
    isActive: json['isActive'] as bool,
    createdDate: DateTime.parse(json['createdDate'] as String),
    updatedDate: DateTime.parse(json['updatedDate'] as String),
  );

  final int id;
  final String name;
  final bool isActive;
  final DateTime createdDate;
  final DateTime updatedDate;

  @override
  List<Object> get props => [id, name, isActive, createdDate, updatedDate];

  BlacklistedTag copyWith({
    int? id,
    String? name,
    bool? isActive,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return BlacklistedTag(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isActive': isActive,
    'createdDate': createdDate.toIso8601String(),
    'updatedDate': updatedDate.toIso8601String(),
  };
}

List<String>? sanitizeBlacklistTagString(String tagString) {
  final trimmed = tagString.trim();
  final tags = trimmed.split('\n');

  if (tags.isEmpty) return null;

  return tags;
}
