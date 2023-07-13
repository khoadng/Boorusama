// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

class RelatedTagDto {
  final String? query;
  final int? postCount;
  final TagDto? tag;
  final List<TagDetailDto>? relatedTags;
  final List<TagDto>? wikiPageTags;

  RelatedTagDto({
    this.query,
    this.postCount,
    this.tag,
    this.relatedTags,
    this.wikiPageTags,
  });

  factory RelatedTagDto.fromJson(Map<String, dynamic> json) => RelatedTagDto(
        query: json['query'],
        postCount: json['post_count'],
        tag: json['tag'] != null ? TagDto.fromJson(json['tag']) : null,
        relatedTags: json['related_tags'] != null
            ? (json['related_tags'] as List)
                .map((data) => TagDetailDto.fromJson(data))
                .toList()
            : null,
        wikiPageTags: json['wiki_page_tags'] != null
            ? (json['wiki_page_tags'] as List)
                .map((data) => TagDto.fromJson(data))
                .toList()
            : null,
      );
}

class TagDetailDto {
  final TagDto? tag;
  final double? cosineSimilarity;
  final double? jaccardSimilarity;
  final double? overlapCoefficient;
  final double? frequency;

  TagDetailDto({
    this.tag,
    this.cosineSimilarity,
    this.jaccardSimilarity,
    this.overlapCoefficient,
    this.frequency,
  });

  factory TagDetailDto.fromJson(Map<String, dynamic> json) => TagDetailDto(
        tag: json['tag'] != null ? TagDto.fromJson(json['tag']) : null,
        cosineSimilarity: json['cosine_similarity']?.toDouble(),
        jaccardSimilarity: json['jaccard_similarity']?.toDouble(),
        overlapCoefficient: json['overlap_coefficient']?.toDouble(),
        frequency: json['frequency']?.toDouble(),
      );
}
