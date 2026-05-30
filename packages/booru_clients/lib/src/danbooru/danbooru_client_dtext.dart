// Package imports:
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;

// Project imports:
import 'types/types.dart';

mixin DanbooruClientDText {
  Dio get dio;

  Future<String> createDTextPreview({
    required String body,
    bool inline = false,
    bool disableMentions = false,
    bool mediaEmbeds = true,
  }) async {
    final response = await dio.post<String>(
      '/dtext_preview',
      data: {
        'body': body,
        'inline': inline.toString(),
        'disable_mentions': disableMentions.toString(),
        'media_embeds': mediaEmbeds.toString(),
      },
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    return response.data ?? '';
  }

  Future<Map<String, DanbooruDTextEmojiValue>> getDTextEmojiValues(
    Set<String> names,
  ) async {
    if (names.isEmpty) return const {};

    final html = await createDTextPreview(
      body: names.map((name) => ':$name:').join(' '),
      inline: true,
      disableMentions: true,
      mediaEmbeds: false,
    );

    return parseDTextEmojiValues(html);
  }

  Map<String, DanbooruDTextEmojiValue> parseDTextEmojiValues(String html) {
    final fragment = html_parser.parseFragment(html);
    final emojis = <String, DanbooruDTextEmojiValue>{};

    for (final element in fragment.querySelectorAll('emoji')) {
      final name = element.attributes['data-name']?.toLowerCase();
      if (name == null || name.isEmpty) continue;

      final image = _extractEmojiImage(element);
      if (image != null) {
        emojis[name] = image;
        continue;
      }

      final text = element.text;
      if (text.isNotEmpty) {
        emojis[name] = DanbooruDTextEmojiText(text);
      }
    }

    return Map.unmodifiable(emojis);
  }

  DanbooruDTextEmojiImage? _extractEmojiImage(html_dom.Element element) {
    final image = element.querySelector('img');
    final source = image?.attributes['src'];
    if (source == null || source.isEmpty) return null;

    return DanbooruDTextEmojiImage(
      _absoluteUrl(source),
      width: int.tryParse(image?.attributes['width'] ?? ''),
      height: int.tryParse(image?.attributes['height'] ?? ''),
    );
  }

  String _absoluteUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    if (uri.hasScheme) return value;

    return Uri.parse(dio.options.baseUrl).resolveUri(uri).toString();
  }
}
