// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../configs/ref.dart';
import '../http/providers.dart';

const _unknownSize = 26.0;
const _faviconSize = 32.0;

double? _calcFailedIconSize(
  double size, {
  double defaultSize = _unknownSize,
  double referenceSize = _faviconSize,
}) {
  final ratio = defaultSize / referenceSize;

  return size * ratio;
}

class WebsiteLogo extends ConsumerWidget {
  const WebsiteLogo({
    required this.url,
    super.key,
    this.size = _faviconSize,
  });

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));
    final url = this.url;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size,
        minWidth: size,
        minHeight: size,
      ),
      child: url != null
          ? ExtendedImage.network(
              url,
              dio: dio,
              clearMemoryCacheIfFailed: false,
              fit: BoxFit.cover,
              retries: 1,
              placeholderWidget: Container(
                padding: const EdgeInsets.all(8),
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              ),
              errorWidget: _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Card(
      child: FaIcon(
        FontAwesomeIcons.globe,
        size: _calcFailedIconSize(size),
        color: Colors.blue,
      ),
    );
  }
}
