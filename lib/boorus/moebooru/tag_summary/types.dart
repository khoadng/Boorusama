// Package imports:
import 'package:booru_clients/moebooru.dart';

class TagSummary {
  TagSummary({
    required this.category,
    required this.name,
    required this.otherNames,
  });
  final int category;
  final String name;
  final List<String> otherNames;
}

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}

abstract class TagSummaryStore {
  Future<TagSummaryDto?> get();
  Future<void> save(TagSummaryDto dto);
  Future<void> clear();
}

class EmptyTagSummaryStore implements TagSummaryStore {
  @override
  Future<TagSummaryDto?> get() async => null;

  @override
  Future<void> save(TagSummaryDto dto) async {
    // No-op
  }

  @override
  Future<void> clear() async {
    // No-op
  }
}
