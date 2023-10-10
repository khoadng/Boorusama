// Package imports:
import 'package:html/dom.dart';
import 'package:xml/xml.dart';

class TagDto {
  TagDto({
    required this.id,
    required this.name,
    required this.count,
    required this.type,
    required this.ambiguous,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      type: json['type'],
      ambiguous: json['ambiguous'],
    );
  }

  factory TagDto.fromXml(XmlElement xmlElement) {
    return TagDto(
      id: int.parse(xmlElement.getAttribute('id')!),
      name: xmlElement.getAttribute('name'),
      count: int.parse(xmlElement.getAttribute('count')!),
      type: int.parse(xmlElement.getAttribute('type')!),
      ambiguous: int.tryParse(xmlElement.getAttribute('ambiguous') ?? ''),
    );
  }

  factory TagDto.fromHtml(Element element, int type) {
    return TagDto(
      id: null,
      name: _parseNameFromElement(element),
      count: _parseCountFromElement(element),
      type: type,
      ambiguous: null,
    );
  }

  final int? id;
  final String? name;
  final int? count;
  final int? type;
  final int? ambiguous;

  @override
  String toString() => name ?? '';
}

String? _parseNameFromElement(Element tag) =>
    tag.nodes.length >= 4 ? tag.nodes[3].text?.replaceAll(' ', '_') : null;

int? _parseCountFromElement(Element tag) =>
    tag.nodes.length >= 6 ? int.tryParse(tag.nodes[5].text ?? '') : null;
