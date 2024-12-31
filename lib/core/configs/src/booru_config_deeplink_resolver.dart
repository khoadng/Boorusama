// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/loggers.dart';
import 'booru_config.dart';
import 'booru_config_ref.dart';
import 'manage/booru_config_provider.dart';
import 'manage/current_booru_providers.dart';

class BooruConfigDeepLinkResolver extends ConsumerStatefulWidget {
  const BooruConfigDeepLinkResolver({
    required this.path,
    required this.child,
    super.key,
  });

  final String? path;
  final Widget child;

  @override
  ConsumerState<BooruConfigDeepLinkResolver> createState() =>
      _BooruConfigDeepLinkResolverState();
}

class _BooruConfigDeepLinkResolverState
    extends ConsumerState<BooruConfigDeepLinkResolver> {
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    final config = _getConfigFromLink(widget.path);

    if (config == null) {
      _initialized = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(currentBooruConfigProvider.notifier).update(config);
        _print('Deep link config updated');
        setState(() {
          _initialized = true;
        });
      });
    }
  }

  void _print(String message) {
    if (!kDebugMode) return;

    ref.read(loggerProvider).logI('Deeplink', message);
  }

  @override
  void didUpdateWidget(covariant BooruConfigDeepLinkResolver oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      final config = _getConfigFromLink(widget.path);

      if (config != null) {
        return WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref.read(currentBooruConfigProvider.notifier).update(config);

          _print('Deep link config updated');
        });
      }
    }
  }

  BooruConfig? _getConfigFromLink(String? path) {
    final uri = path != null ? Uri.parse(path) : null;

    if (uri == null) return null;

    _print('Deep link: $uri');

    // check for '/?cid=1' format only '/settings/?cid=1' is not allowed
    final isBooruConfigDeepLink = uri.pathSegments.isEmpty;

    if (!isBooruConfigDeepLink) return null;

    _print('Deep link is booru config deep link');

    final configIdString = uri.queryParameters['cid'];
    final configId =
        configIdString != null ? int.tryParse(configIdString) : null;

    if (configId == null) return null;

    _print('Deep link config id: $configId');

    final currentConfigId = ref.readConfig.id;

    if (configId == currentConfigId) return null;

    _print('Deep link config id not same as current config id');

    final config = ref
        .read(booruConfigProvider)
        .where((element) => element.id == configId)
        .firstOrNull;

    if (config == null) return null;

    _print('Deep link config found: $config');

    return config;
  }

  @override
  Widget build(BuildContext context) {
    return _initialized ? widget.child : const SizedBox.shrink();
  }
}
