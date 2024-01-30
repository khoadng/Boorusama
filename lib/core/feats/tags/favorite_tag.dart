// Package imports:
import 'package:equatable/equatable.dart';

class FavoriteTag extends Equatable {
  const FavoriteTag({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
  });

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
    var labels = this.labels ?? [];

    final data = labels.where((e) => e.isNotEmpty).toSet();

    return copyWith(
      labels: () => data.toList(),
    );
  }

  FavoriteTag removeLabel(String label) {
    final labels = [...(this.labels ?? <String>[])];

    labels.remove(label);

    return copyWith(
      labels: () => labels,
    );
  }
}
