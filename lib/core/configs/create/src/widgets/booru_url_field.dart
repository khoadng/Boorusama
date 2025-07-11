// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/providers.dart';
import 'create_booru_site_url_field.dart';

class BooruUrlField extends ConsumerWidget {
  const BooruUrlField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
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
      ],
    );
  }
}
