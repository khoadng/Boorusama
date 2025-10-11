// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/url_launcher.dart';
import '../../../../artists/urls/widgets.dart';
import '../../../../sources/providers.dart';
import '../providers/upload_provider.dart';
import '../types/danbooru_upload_post.dart';

class TagEditUploadSource extends ConsumerWidget {
  const TagEditUploadSource({
    super.key,
    required this.post,
  });

  final DanbooruUploadPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final uploadNotifier = ref.watch(
      danbooruUploadNotifierProvider(config).notifier,
    );

    ref.listen(
      danbooruSourceProvider(post.pageUrl),
      (previous, next) {
        switch (next) {
          case AsyncData(:final value):
            uploadNotifier.updateFromSource(
              artistCommentary: value.artistCommentary,
            );
          case _:
            break;
        }
      },
    );

    return CustomScrollView(
      slivers: [
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 80,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: ref
                .watch(danbooruSourceProvider(post.pageUrl))
                .when(
                  data: (source) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      switch (source.artist) {
                        final artist? => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (artist.displayName
                                        case final displayName?)
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ref.watch(
                                            tagColorProvider(
                                              (ref.watchConfigAuth, 'artist'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (artist.artists case final artists?
                                        when artists.isNotEmpty)
                                      ...artists.map(
                                        (artistInfo) => Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            artistInfo.name ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (artist.profileUrls case final urls?
                                        when urls.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      DanbooruArtistUrlChips(
                                        alignment: WrapAlignment.start,
                                        artistUrls: urls,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(
                                        danbooruSourceProvider(
                                          post.pageUrl,
                                        ).notifier,
                                      )
                                      .fetch();
                                },
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ),
                        null => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 16),
                            const Text('???'),
                            const Spacer(),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final url =
                                    '${ref.readConfigAuth.url}/artists/new?artist[source]=${post.pageUrl}';
                                launchExternalUrlString(url);
                              },
                              child: Text(context.t.generic.action.create),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      },
                    ],
                  ),
                  error: (e, _) => Text(e.toString()),
                  loading: () => const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
          ),
        ),
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: BooruTextFormField(
              initialValue: post.pageUrl,
              readOnly: true,
              autocorrect: false,
              keyboardType: TextInputType.url,
              autofillHints: const [
                AutofillHints.url,
              ],
              validator: (p0) => null,
              decoration: const InputDecoration(
                labelText: 'Source',
              ),
            ),
          ),
        ),
        const SliverSizedBox(height: 16),
        switch (ref.watch(danbooruSourceProvider(post.pageUrl))) {
          AsyncData(:final value) => SliverToBoxAdapter(
            child: AutofillGroup(
              child: BooruTextFormField(
                initialValue:
                    ref.watch(
                      danbooruUploadNotifierProvider(
                        config,
                      ).select((state) => state.originalTitle),
                    ) ??
                    value.artistCommentary?.dtextTitle,
                readOnly: true,
                autocorrect: false,
                validator: (p0) => null,
                onChanged: uploadNotifier.updateOriginalTitle,
                decoration: const InputDecoration(
                  labelText: 'Original Title',
                ),
              ),
            ),
          ),
          _ => const SliverSizedBox.shrink(),
        },
        const SliverSizedBox(height: 16),
        switch (ref.watch(danbooruSourceProvider(post.pageUrl))) {
          AsyncData(:final value) => SliverToBoxAdapter(
            child: AutofillGroup(
              child: BooruTextFormField(
                initialValue:
                    ref.watch(
                      danbooruUploadNotifierProvider(
                        config,
                      ).select((state) => state.originalDescription),
                    ) ??
                    value.artistCommentary?.dtextDescription,
                readOnly: true,
                autocorrect: false,
                validator: (p0) => null,
                minLines: 3,
                maxLines: 3,
                onChanged: uploadNotifier.updateOriginalDescription,
                decoration: const InputDecoration(
                  labelText: 'Original Description',
                ),
              ),
            ),
          ),
          _ => const SliverSizedBox.shrink(),
        },
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: BooruTextFormField(
              initialValue: ref.watch(
                danbooruUploadNotifierProvider(
                  config,
                ).select((state) => state.translatedTitle),
              ),
              autocorrect: false,
              validator: (p0) => null,
              onChanged: uploadNotifier.updateTranslatedTitle,
              decoration: const InputDecoration(
                labelText: 'Translated Title',
              ),
            ),
          ),
        ),
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: BooruTextFormField(
              initialValue: ref.watch(
                danbooruUploadNotifierProvider(
                  config,
                ).select((state) => state.translatedDescription),
              ),
              autocorrect: false,
              onChanged: uploadNotifier.updateTranslatedDescription,
              validator: (p0) => null,
              minLines: 3,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Translated Description',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
