// Package imports:
import 'package:equatable/equatable.dart';

const savedSearchHelpUrl =
    'https://safebooru.donmai.us/wiki_pages/help%3Asaved_searches';

class SavedSearch extends Equatable {
  const SavedSearch({
    required this.id,
    required this.query,
    required this.labels,
    required this.createdAt,
    required this.updatedAt,
    required this.canDelete,
  });

  factory SavedSearch.empty() => SavedSearch(
        id: -1,
        query: '',
        labels: const [],
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        canDelete: false,
      );

  factory SavedSearch.all() => SavedSearch(
        id: 0,
        query: '',
        labels: const ['all'],
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        canDelete: false,
      );

  final int id;
  final String query;
  final List<String> labels;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool canDelete;

  @override
  List<Object?> get props =>
      [id, query, labels, createdAt, updatedAt, canDelete];
}

extension SavedSearchX on SavedSearch {
  SavedSearch copyWith({
    int? id,
    String? query,
    List<String>? labels,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? canDelete,
  }) =>
      SavedSearch(
        id: id ?? this.id,
        query: query ?? this.query,
        labels: labels ?? this.labels,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        canDelete: canDelete ?? this.canDelete,
      );

  String toQuery() => labels.isEmpty ? 'search:all' : 'search:${labels.first}';

  bool get readOnly => !canDelete;
}
