// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/theme.dart';
import '../../../foundation/path.dart';

class Shimmie2BooruUrlField extends ConsumerWidget {
  const Shimmie2BooruUrlField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editId = ref.watch(editBooruConfigIdProvider);
    final notifier = ref.watch(editBooruConfigProvider(editId).notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateBooruSiteUrlField(
          text: config.url,
          onChanged: (value) => notifier.updateUrl(value),
        ),
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
