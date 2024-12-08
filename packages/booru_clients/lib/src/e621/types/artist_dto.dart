class ArtistDto {

  ArtistDto({
    this.id,
    this.name,
    this.updatedAt,
    this.isActive,
    this.otherNames,
    this.groupName,
    // this.linkedUserId,
    this.createdAt,
    this.creatorId,
    this.isLocked,
    // this.notes,
    this.domains,
    this.urls,
  });

  factory ArtistDto.fromJson(Map<String, dynamic> json) {
    final List<UrlDto>? urlList = (json['urls'] as List<dynamic>?)
        ?.map((url) => UrlDto.fromJson(url))
        .toList();

    return ArtistDto(
      id: json['id'],
      name: json['name'],
      updatedAt: DateTime.tryParse(json['updated_at']),
      isActive: json['is_active'],
      otherNames: (json['other_names'] as List<dynamic>?)
          ?.map((otherName) => otherName as String)
          .toList(),
      groupName: json['group_name'],
      // linkedUserId: json['linked_user_id'],
      createdAt: DateTime.tryParse(json['created_at']),
      creatorId: json['creator_id'],
      isLocked: json['is_locked'],
      // notes: json['notes'],
      domains: (json['domains'] as List<dynamic>?)
          ?.map((domain) => List<dynamic>.from(domain))
          .toList(),
      urls: urlList,
    );
  }
  final int? id;
  final String? name;
  final DateTime? updatedAt;
  final bool? isActive;
  final List<String>? otherNames;
  final String? groupName;
  // final int? linkedUserId;
  final DateTime? createdAt;
  final int? creatorId;
  final bool? isLocked;
  // final Map<String, dynamic>? notes;
  final List<List<dynamic>>? domains;
  final List<UrlDto>? urls;

  @override
  String toString() => name ?? '';
}

class UrlDto {

  UrlDto({
    this.id,
    this.artistId,
    this.url,
    this.normalizedUrl,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  factory UrlDto.fromJson(Map<String, dynamic> json) {
    return UrlDto(
      id: json['id'],
      artistId: json['artist_id'],
      url: json['url'],
      normalizedUrl: json['normalized_url'],
      createdAt: DateTime.tryParse(json['created_at']),
      updatedAt: DateTime.tryParse(json['updated_at']),
      isActive: json['is_active'],
    );
  }
  final int? id;
  final int? artistId;
  final String? url;
  final String? normalizedUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
}
