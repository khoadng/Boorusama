class TagDto {
  final String? aliasedTag;
  final List<String>? aliases;
  final String? category;
  final String? description;
  // final List<dynamic> dnpEntries;
  final int? id;
  final int? images;
  final List<String>? impliedByTags;
  final List<String>? impliedTags;
  final String? name;
  final String? nameInNamespace;
  // final dynamic namespace;
  final String? shortDescription;
  final String? slug;
  // final dynamic spoilerImageUri;

  TagDto({
    this.aliasedTag,
    this.aliases,
    this.category,
    this.description,
    // this.dnpEntries = const [],
    this.id,
    this.images,
    this.impliedByTags,
    this.impliedTags,
    this.name,
    this.nameInNamespace,
    // this.namespace,
    this.shortDescription,
    this.slug,
    // this.spoilerImageUri,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      aliasedTag: json['aliased_tag'],
      aliases:
          (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList(),
      category: json['category'],
      description: json['description'],
      // dnpEntries: json['dnp_entries'] ?? [],
      id: json['id'],
      images: json['images'],
      impliedByTags: (json['implied_by_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      impliedTags: (json['implied_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      name: json['name'],
      nameInNamespace: json['name_in_namespace'],
      // namespace: json['namespace'],
      shortDescription: json['short_description'],
      slug: json['slug'],
      // spoilerImageUri: json['spoiler_image_uri'],
    );
  }

  @override
  String toString() => '$name';
}
