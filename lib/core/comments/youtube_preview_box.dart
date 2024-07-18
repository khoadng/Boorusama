// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:html/parser.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';

class YoutubePreviewBox extends StatelessWidget {
  const YoutubePreviewBox({
    super.key,
    required this.uri,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    try {
      return FutureBuilder<PreviewUrlData>(
        future: Dio()
            .getUri(uri)
            .then((value) => value.data)
            .then((value) => parseHtmlAsync(value, uri.toString())),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.siteName,
                      style: context.textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: () => launchExternalUrl(uri),
                      child: Text(
                        data.title,
                        style: context.textTheme.titleMedium!
                            .copyWith(color: Colors.blue),
                      ),
                    ),
                    if (data.previewImage != null)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              child: ExtendedImage.network(
                                data.previewImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (data.isVideo)
                              Align(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.black87,
                                  ),
                                  child: IconButton(
                                    onPressed: () => launchExternalUrl(uri),
                                    icon: const Icon(Symbols.play_arrow),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}

class PreviewUrlData {
  const PreviewUrlData({
    required this.siteName,
    required this.title,
    required this.description,
    required this.isVideo,
    this.previewImage,
  });
  final String siteName;
  final bool isVideo;
  final String title;
  final String description;
  final String? previewImage;
}

class _MetaElement {
  const _MetaElement(this.property, this.content);

  final String property;
  final String content;
}

PreviewUrlData parseHtml(String text) {
  final html = parse(text);
  final metas = html.getElementsByTagName('meta');

  final props = metas
      .where((e) => e.attributes['property']?.isNotEmpty ?? false)
      .map((e) => _MetaElement(
            e.attributes['property']!,
            e.attributes['content'] ?? '',
          ));

  final propMap = {for (final p in props) p.property: p.content};

  return PreviewUrlData(
    siteName: propMap['og:site_name'] ?? '',
    description: propMap['og:description'] ?? '',
    title: propMap['og:title'] ?? '',
    isVideo: (propMap['og:type'] ?? '').contains('video'),
    previewImage: propMap['og:image'],
  );
}

Future<PreviewUrlData> parseHtmlAsync(String text, String sourceUrl) {
  return compute(parseHtml, text);
}
