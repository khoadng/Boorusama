// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/moebooru/feats/downloads/download_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_provider.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';

class MoebooruProvider extends StatelessWidget {
  const MoebooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        bulkDownloadFileNameProvider
            .overrideWithValue(Md5OnlyFileNameGenerator()),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(moebooruDownloadFileNameGeneratorProvider)),
        tagRepoProvider
            .overrideWith((ref) => ref.watch(moebooruTagRepoProvider)),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final moebooruClientProvider = Provider<MoebooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return MoebooruClient.custom(
    baseUrl: booruConfig.url,
    dio: dio,
  );
});
