// Package imports:
import 'package:html/parser.dart' as html_parser;

class ExtensionDto {
  ExtensionDto({
    required this.name,
    required this.description,
    required this.category,
    this.docLink,
  });

  factory ExtensionDto.fromHtmlRow({
    required dynamic row,
    required String category,
    String? baseUrl,
  }) {
    final extName = row.attributes['data-ext'];
    if (extName == null) {
      throw Exception('Extension row missing data-ext attribute');
    }

    final cells = row.querySelectorAll('td');
    if (cells.length < 3) {
      throw Exception('Extension row has insufficient cells');
    }

    final description = cells[2].text.trim();
    final docAnchor = cells[1].querySelector('a');
    final docLink = docAnchor?.attributes['href'];
    final resolvedDocLink = _resolveDocLink(docLink, baseUrl);

    return ExtensionDto(
      name: extName,
      description: description,
      category: category,
      docLink: resolvedDocLink,
    );
  }

  static ExtensionsResult parseFromHtml(String html, {String? baseUrl}) {
    try {
      final document = html_parser.parse(html);
      final extensionsTable = document.getElementById('extensions');

      if (extensionsTable == null) {
        return ExtensionsNotSupported();
      }

      final extensions = <ExtensionDto>[];
      var currentCategory = '';

      final rows = extensionsTable.querySelectorAll('tbody tr');

      for (final row in rows) {
        if (row.classes.contains('category')) {
          final categoryHeader = row.querySelector('th');
          currentCategory = categoryHeader?.text.trim() ?? '';
          continue;
        }

        final extName = row.attributes['data-ext'];
        if (extName == null) continue;

        try {
          extensions.add(
            ExtensionDto.fromHtmlRow(
              row: row,
              category: currentCategory,
              baseUrl: baseUrl,
            ),
          );
        } catch (_) {
          continue;
        }
      }

      return ExtensionsSuccess(extensions);
    } catch (_) {
      return ExtensionsNotSupported();
    }
  }

  final String name;
  final String description;
  final String category;
  final String? docLink;

  @override
  String toString() => '$category - $name: $description';
}

String? _resolveDocLink(String? docLink, String? baseUrl) =>
    switch ((docLink, baseUrl)) {
      (null, _) => null,
      (final link?, _)
          when link.startsWith('http://') || link.startsWith('https://') =>
        link,
      (final link?, final base?) => Uri.parse(base).resolve(link).toString(),
      (final link?, null) => link,
    };

sealed class ExtensionsResult {}

class ExtensionsSuccess extends ExtensionsResult {
  ExtensionsSuccess(this.extensions);

  final List<ExtensionDto> extensions;
}

class ExtensionsNotSupported extends ExtensionsResult {}
