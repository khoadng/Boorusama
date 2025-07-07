// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../tag/tag.dart';

class TagInfo extends Equatable {
  const TagInfo({
    required this.siteHost,
    required this.tagName,
    required this.category,
    this.postCount,
    this.metadata,
  });

  factory TagInfo.fromTag({
    required String siteHost,
    required Tag tag,
    Map<String, dynamic>? additionalMetadata,
  }) {
    return TagInfo(
      siteHost: siteHost,
      tagName: tag.rawName,
      category: tag.category.name,
      postCount: tag.postCount > 0 ? tag.postCount : null,
      metadata: additionalMetadata,
    );
  }

  final String siteHost;
  final String tagName;
  final String category;
  final int? postCount;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
    siteHost,
    tagName,
    category,
    postCount,
    metadata,
  ];
}
