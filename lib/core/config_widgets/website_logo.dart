// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/ref.dart';
import '../http/providers.dart';
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
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioForWidgetProvider(config));

    return WebsiteLogo(
      url: url,
      dio: dio,
      size: size,
    );
  }
}
