// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:html/dom.dart';
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

      return ExtensionsSuccess(
        extensions: extensions,
        version: _parseShimmieVersion(document),
      );
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

Version? _parseShimmieVersion(Document document) {
  return switch (document.querySelector('footer')?.text) {
    null => null,
    final footerText => switch (RegExp(
      r'Shimmie version\s+(\S+)',
    ).firstMatch(footerText)?.group(1)) {
      null => null,
      final versionString => Version.tryParse(versionString),
    },
  };
}

sealed class ExtensionsResult {}

class ExtensionsSuccess extends ExtensionsResult {
  ExtensionsSuccess({
    required this.extensions,
    this.version,
  });

  final List<ExtensionDto> extensions;
  final Version? version;
}

class ExtensionsNotSupported extends ExtensionsResult {}
