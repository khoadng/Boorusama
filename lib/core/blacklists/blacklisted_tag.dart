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
}

abstract class GlobalBlacklistedTagRepository {
  Future<BlacklistedTag?> addTag(String tag);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
  Future<BlacklistedTag> updateTag(int tagId, String newTag);
}

List<String>? sanitizeBlacklistTagString(String tagString) {
  final trimmed = tagString.trim();
  final tags = trimmed.split('\n');

  if (tags.isEmpty) return null;

  return tags;
}
