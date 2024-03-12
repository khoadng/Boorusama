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
    final nodes = element.nodes
        .map((e) => e.text?.trim())
        .where((e) => e != null && e.isNotEmpty && e != '?')
        .toList();

    return TagDto(
      id: null,
      name: _parseNameFromElement(nodes),
      count: _parseCountFromElement(nodes),
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

String? _parseNameFromElement(List<String?> nodes) =>
    nodes.length >= 2 ? nodes[0]?.replaceAll(' ', '_') : null;

int? _parseCountFromElement(List<String?> nodes) =>
    nodes.length >= 2 ? int.tryParse(nodes[1] ?? '') : null;
