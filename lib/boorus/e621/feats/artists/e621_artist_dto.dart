class E621ArtistDto {
  final int? id;
  final String? name;
  final String? updatedAt;
  final bool? isActive;
  final List<String>? otherNames;
  final String? groupName;
  final int? linkedUserId;
  final String? createdAt;
  final int? creatorId;
  final bool? isLocked;
  final String? notes;
  final List<DomainDto>? domains;
  final List<UrlDto>? urls;

  E621ArtistDto({
    this.id,
    this.name,
    this.updatedAt,
    this.isActive,
    this.otherNames,
    this.groupName,
    this.linkedUserId,
    this.createdAt,
    this.creatorId,
    this.isLocked,
    this.notes,
    this.domains,
    this.urls,
  });

  factory E621ArtistDto.fromJson(Map<String, dynamic> json) {
    return E621ArtistDto(
      id: json['id'],
      name: json['name'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],
      otherNames: List<String>.from(json['other_names'] ?? []),
      groupName: json['group_name'],
      linkedUserId: json['linked_user_id'],
      createdAt: json['created_at'],
      creatorId: json['creator_id'],
      isLocked: json['is_locked'],
      notes: json['notes'],
      domains: (json['domains'] as List?)
          ?.map((e) => DomainDto.fromJson(e))
          .toList(),
      urls: (json['urls'] as List?)?.map((e) => UrlDto.fromJson(e)).toList(),
    );
  }
}

class DomainDto {
  final String? domain;
  final int? count;

  DomainDto({this.domain, this.count});

  factory DomainDto.fromJson(List<dynamic> json) {
    return DomainDto(
      domain: json[0],
      count: json[1],
    );
  }
}

class UrlDto {
  final int? id;
  final int? artistId;
  final String? url;
  final String? normalizedUrl;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;

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
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],
    );
  }
}
