// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/downloads/download_provider.dart';
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/tags/related_tag_repository_empty.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/provider.dart';

class DanbooruProvider extends StatelessWidget {
  const DanbooruProvider({
    super.key,
    required this.builder,
    required this.relatedTagRepo,
  });

  factory DanbooruProvider.create(
    BuildContext context, {
    required WidgetRef ref,
    required Widget Function(BuildContext context) builder,
  }) {
    ref.read(trendingTagsProvider.notifier).fetch();

    final relatedTagRepo = RelatedTagRepositoryEmpty();

    return DanbooruProvider(
      builder: builder,
      relatedTagRepo: relatedTagRepo,
    );
  }

  factory DanbooruProvider.of(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
  }) {
    final relatedTagRepo = context.read<RelatedTagRepository>();

    return DanbooruProvider(
      builder: builder,
      relatedTagRepo: relatedTagRepo,
    );
  }

  final Widget Function(BuildContext context) builder;

  final RelatedTagRepository relatedTagRepo;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: relatedTagRepo),
      ],
      child: ProviderScope(
        overrides: [
          tagRepoProvider
              .overrideWith((ref) => ref.watch(danbooruTagRepoProvider)),
          downloadFileNameGeneratorProvider.overrideWith(
              (ref) => ref.watch(danbooruDownloadFileNameGeneratorProvider)),
          autocompleteRepoProvider.overrideWith(
              (ref) => ref.watch(danbooruAutocompleteRepoProvider))
        ],
        child: Builder(builder: builder),
      ),
    );
  }
}

final danbooruApiProvider = Provider<DanbooruApi>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return DanbooruApi(dio);
});

final danbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return AutocompleteRepositoryApi(
    api: api,
    booruConfig: booruConfig,
  );
});
