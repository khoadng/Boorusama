// Project imports:
import 'tag_type.dart';

class TagDto {
  TagDto({
    required this.name,
    required this.count,
    required this.type,
    required this.namespace,
  });

  factory TagDto.fromJson(String tagName, int count) {
    final namespace = tagName.contains(':') ? tagName.split(':')[0] : '';
    final name = tagName.contains(':') ? tagName.split(':')[1] : tagName;

    return TagDto(
      name: name,
      count: count,
      type: TagType.fromNamespace(namespace),
      namespace: namespace,
    );
  }

  final String? name;
  final int count;
  final TagType type;
  final String namespace;

  @override
  String toString() => name ?? '';
}
