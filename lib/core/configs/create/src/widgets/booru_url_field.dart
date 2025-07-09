// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import '../../../../boorus/booru/booru.dart';
import '../../../../theme.dart';
import '../providers/internal_providers.dart';
import '../providers/providers.dart';
import 'create_booru_site_url_field.dart';

class BooruUrlField extends ConsumerWidget {
  const BooruUrlField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final engine = ref.watch(booruEngineProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateBooruSiteUrlField(
          text: config.url,
          onChanged: (value) =>
              ref.read(siteUrlProvider(config).notifier).state = value,
        ),
        if (engine == BooruType.shimmie2)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                children: const [
                  TextSpan(text: 'The app requires the '),
                  TextSpan(
                    text: 'Danbooru Client API',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' extension to be installed on the site to function.',
                  ),
                ],
              ),
            ),
          ),
        if (engine == BooruType.shimmie2)
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),
            onPressed: () {
              launchUrlString(join(config.url, 'ext_doc'));
            },
            child: Text('View extension documentation'.hc),
          ),
      ],
    );
  }
}
