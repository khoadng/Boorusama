// Package imports:
import 'package:html/dom.dart';

class TagDto {
  TagDto({
    required this.value,
    required this.type,
  });

  final String? value;
  final String? type;

  factory TagDto.fromHtmlElement(Element element) {
    // value is the data-tag attribute
    final value = element.attributes['data-tag'] ?? element.text.trim();
    // type is the data-type attribute
    final type = element.attributes['data-type'] ?? element.className.trim();

    return TagDto(
      value: value,
      type: type,
    );
  }
}
