// Package imports:
import 'package:equatable/equatable.dart';

class CachedTag extends Equatable {
  const CachedTag({
    required this.siteHost,
    required this.tagName,
    required this.category,
    this.postCount,
    this.metadata,
    this.updatedAt,
  });

  const CachedTag.unknown({
    required this.siteHost,
    required this.tagName,
  }) : postCount = null,
       category = '',
       metadata = null,
       updatedAt = null;

  final String siteHost;
  final String tagName;
  final String category;
  final int? postCount;
  final Map<String, dynamic>? metadata;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    siteHost,
    tagName,
    category,
    postCount,
    metadata,
    updatedAt,
  ];
}

class TagResolutionResult extends Equatable {
  const TagResolutionResult({
    required this.found,
    required this.missing,
  });

  final List<CachedTag> found;
  final List<String> missing;

  List<CachedTag> get allTags => [
    ...found,
    ...missing.map(
      (tag) => CachedTag.unknown(
        siteHost: '',
        tagName: tag,
      ),
    ),
  ];

  @override
  List<Object?> get props => [found, missing];
}
