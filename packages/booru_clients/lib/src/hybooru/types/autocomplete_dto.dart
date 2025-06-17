class AutocompleteDto {
  const AutocompleteDto({
    this.name,
    this.parents,
    this.siblings,
    this.posts,
  });

  factory AutocompleteDto.fromJson(Map<String, dynamic> json) {
    return AutocompleteDto(
      name: json['name'] as String?,
      parents:
          (json['parents'] as List<dynamic>?)?.map((e) => e as String).toList(),
      siblings: (json['siblings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      posts: json['posts'] as int?,
    );
  }

  final String? name;
  final List<String>? parents;
  final List<String>? siblings;
  final int? posts;

  @override
  String toString() => name ?? '';
}
