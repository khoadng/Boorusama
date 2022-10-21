// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

class YoutubePreviewBox extends StatelessWidget {
  const YoutubePreviewBox({
    Key? key,
    required this.uri,
  }) : super(key: key);

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
                      style: Theme.of(context).textTheme.caption,
                    ),
                    TextButton(
                      onPressed: () => launchExternalUrl(uri),
                      child: Text(
                        data.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
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
                              child: CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageUrl: data.previewImage!,
                              ),
                            ),
                            if (data.isVideo)
                              Align(
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.black87,
                                  ),
                                  child: IconButton(
                                    onPressed: () => launchExternalUrl(uri),
                                    icon: const Icon(Icons.play_arrow),
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
