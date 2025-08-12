// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../http/providers.dart';
import '../images/providers.dart';
import '../widgets/website_logo.dart';

class ConfigAwareWebsiteLogo extends ConsumerWidget {
  const ConfigAwareWebsiteLogo({
    required this.url,
    super.key,
    this.size = kFaviconSize,
  });

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(faviconDioProvider);

    return WebsiteLogo(
      url: url,
      dio: dio,
      size: size,
      cacheManager: ref.watch(defaultImageCacheManagerProvider),
    );
  }
}
