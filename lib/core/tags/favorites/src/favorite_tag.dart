// Package imports:
import 'package:equatable/equatable.dart';

class FavoriteTag extends Equatable {
  const FavoriteTag({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
  });

  factory FavoriteTag.fromJson(Map<String, dynamic> json) => FavoriteTag(
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        labels: (json['labels'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  factory FavoriteTag.empty() => FavoriteTag(
        name: '',
        createdAt: DateTime(1),
        updatedAt: null,
        labels: null,
      );

  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? labels;

  FavoriteTag copyWith({
    String? name,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
    List<String>? Function()? labels,
  }) =>
      FavoriteTag(
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
        labels: labels != null ? labels() : this.labels,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'labels': labels,
      };

  @override
  List<Object?> get props => [
        name,
        createdAt,
        updatedAt,
        labels,
      ];
}

extension FavoriteTagX on FavoriteTag {
  FavoriteTag ensureValid() {
    final labels = this.labels ?? [];

    final data = labels.where((e) => e.isNotEmpty).toSet();

    return copyWith(
      labels: () => data.toList(),
    );
  }

  FavoriteTag removeLabel(String label) {
    final labels = [
      ...(this.labels ?? <String>[]),
    ]..remove(label);

    return copyWith(
      labels: () => labels,
    );
  }
}

abstract class FavoriteTagRepository {
  Future<List<FavoriteTag>> get(String name);

  Future<List<FavoriteTag>> getAll();

  Future<FavoriteTag?> getFirst(String name);

  Future<FavoriteTag?> deleteFirst(String name);

  Future<FavoriteTag> create({
    required String name,
    List<String>? labels,
  });

  Future<List<FavoriteTag>> createFrom(List<FavoriteTag> tags);

  Future<FavoriteTag?> updateFirst(String name, FavoriteTag tag);
}
