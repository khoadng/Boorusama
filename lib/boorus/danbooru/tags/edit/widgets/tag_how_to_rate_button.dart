// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/foundation/url_launcher.dart';

const _kHowToRateUrlPath = 'wiki_pages/howto:rate';

final _howToRateUrlProvider = Provider<String>((ref) {
  final config = ref.watchConfigAuth;

  return join(config.url, _kHowToRateUrlPath);
});

class TagHowToRateButton extends ConsumerWidget {
  const TagHowToRateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(_howToRateUrlProvider);

    return IconButton(
      splashRadius: 20,
      visualDensity: VisualDensity.compact,
      onPressed: () => launchExternalUrlString(url),
      icon: const Icon(
        FontAwesomeIcons.circleQuestion,
        size: 16,
      ),
    );
  }
}
