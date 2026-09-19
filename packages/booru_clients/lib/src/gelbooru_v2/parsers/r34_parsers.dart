import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../../common/feature.dart';
import '../../gelbooru/types/types.dart';
import '../post_v2_dto.dart';
import '../types.dart';
import 'common.dart';

PostV2Dto? parseR34PostHtml(
  Response response,
  Map<String, dynamic> context,
) => parseDefaultPostHtml(
  response,
  context,
  imageExtractor: DefaultHtmlImageExtractor(
    hashRegexPattern: r'/([a-f0-9]{40})\.[^/]*$',
    directoryRegexPattern: r'//images/(\d+)/',
    jsDirRegexPattern: r"'dir':\s*(\d+)",
    sampleHostTransform: (url) => switch (Uri.tryParse(url)) {
      Uri(host: final host) when !host.contains('wimg.') =>
        Uri.tryParse(url)?.replace(host: 'wimg.$host').toString() ?? url,
      _ => url,
    },
  ),
);

CommentPageDto parseR34CommentsHtml(
  Response response,
  Map<String, dynamic> context,
) {
  final html = response.data;
  if (html is! String) return const CommentPageDto(comments: []);

  final document = parse(html);
  final commentList = document.getElementById('comment-list');
  if (commentList == null) return const CommentPageDto(comments: []);

  final postId = _parsePositiveInt(context[P.postId]);
  final fallbackScores = _extractR34ScriptScores(document);
  final comments = <CommentDto>[];

  for (final element in commentList.querySelectorAll('[id]')) {
    final commentId = _parseCommentId(element.attributes['id']);
    if (commentId == null) continue;

    final header = element.querySelector('.col1');
    final body = element.querySelector('.col2');
    final score = _parseScore(
      element.querySelector('#sc$commentId')?.text,
      fallbackScores[commentId],
    );
    final createdAt = _extractCreatedAt(header?.text);
    final creator = _extractCreator(header);

    comments.add(
      CommentDto(
        id: commentId.toString(),
        postId: postId?.toString(),
        creator: creator?.isNotEmpty == true ? creator : null,
        creatorId: null,
        createdAt: createdAt,
        body: body == null ? '' : _extractBodyText(body),
        score: score,
      ),
    );
  }

  return CommentPageDto(
    comments: comments,
    nextCursor: _extractNextCommentCursor(document, postId),
  );
}

String? _extractNextCommentCursor(Document document, int? postId) {
  const urlAttributes = ['href', 'data-href', 'data-url', 'hx-get'];

  final paginatorElements = document.querySelectorAll(
    '#paginator [href], #paginator [data-href], '
    '#paginator [data-url], #paginator [hx-get]',
  );
  for (final element in paginatorElements) {
    for (final attribute in urlAttributes) {
      final value = element.attributes[attribute];
      if (value == null || !value.contains('cursor=')) continue;

      final uri = Uri.tryParse(value.replaceAll('&amp;', '&'));
      final cursor = uri?.queryParameters[P.cursor]?.trim();
      if (cursor == null || cursor.isEmpty) continue;

      final linkedPostId = _parsePositiveInt(uri?.queryParameters['id']);
      final tags = uri?.queryParameters[P.tags];
      final belongsToPost =
          postId == null || linkedPostId == postId || tags == 'id:$postId';
      if (belongsToPost) return cursor;
    }
  }

  return null;
}

String? _extractCreator(Element? header) {
  if (header == null) return null;

  final creator = header
      .querySelector('a[href*="page=account"][href*="s=profile"]')
      ?.text
      .trim();

  return creator?.isNotEmpty == true ? creator : null;
}

int? _parsePositiveInt(Object? value) {
  final result = switch (value) {
    final int value => value,
    final String value => int.tryParse(value.trim()),
    _ => null,
  };

  return result != null && result > 0 ? result : null;
}

int? _parseCommentId(String? value) {
  final match = RegExp(r'^c([1-9]\d*)$').firstMatch(value ?? '');
  return int.tryParse(match?.group(1) ?? '');
}

String? _extractCreatedAt(String? value) {
  final match = RegExp(
    r'Posted\s+on\s+(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})',
  ).firstMatch(value ?? '');
  return match?.group(1);
}

int? _parseScore(String? value, int? fallback) {
  final score = int.tryParse(value?.trim() ?? '');
  return score ?? fallback;
}

String _extractBodyText(Element element) {
  final buffer = StringBuffer();

  void visit(Node node) {
    if (node is Text) {
      buffer.write(node.data);
      return;
    }

    if (node is Element) {
      if (_isQuoteElement(node)) {
        buffer.write('[quote]\n');
        for (final child in node.nodes) {
          visit(child);
        }
        buffer.write('\n[/quote]\n');
        return;
      }

      if (node.localName == 'br') {
        buffer.write('\n');
        return;
      }
    }

    for (final child in node.nodes) {
      visit(child);
    }
  }

  visit(element);
  return buffer.toString().trim();
}

bool _isQuoteElement(Element element) =>
    element.localName == 'blockquote' ||
    (element.localName == 'div' && element.classes.contains('quote'));

Map<int, int> _extractR34ScriptScores(Document document) {
  final scores = <int, int>{};
  final assignmentPattern = RegExp(
    r'posts\s*\[\s*\d+\s*\]\s*\.\s*comments\s*\[\s*(\d+)\s*\]\s*=\s*\{([^}]*)\}',
    dotAll: true,
  );
  final scorePattern = RegExp(r'''["']score["']\s*:\s*(-?\d+)''');

  for (final script in document.querySelectorAll('script')) {
    for (final assignment in assignmentPattern.allMatches(script.text)) {
      final commentId = int.tryParse(assignment.group(1) ?? '');
      final score = int.tryParse(
        scorePattern.firstMatch(assignment.group(2) ?? '')?.group(1) ?? '',
      );
      if (commentId != null && commentId > 0 && score != null) {
        scores[commentId] = score;
      }
    }
  }

  return scores;
}
