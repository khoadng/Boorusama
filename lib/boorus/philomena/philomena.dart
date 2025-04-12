// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/artists/artists.dart';
import '../../core/autocompletes/autocompletes.dart';
import '../../core/blacklists/blacklist.dart';
import '../../core/blacklists/providers.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/details/details.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/tag/colors.dart';
import '../../core/tags/tag/providers.dart';
import '../../core/tags/tag/tag.dart';
import '../../core/theme.dart';
import '../danbooru/danbooru.dart';
import '../gelbooru_v2/gelbooru_v2.dart';
import 'create_philomena_config_page.dart';
import 'philomena_post.dart';
import 'providers.dart';

class PhilomenaBuilder
    with
        FavoriteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  PhilomenaBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat: null,
            ),
            child: CreatePhilomenaConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreatePhilomenaConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as PhilomenaPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<PhilomenaPost>(),
        );
      };

  @override
  TagColorBuilder get tagColorBuilder => (options) => switch (options.tagType) {
        'error' => options.colors.get('error'),
        'rating' => options.colors.get('rating'),
        'origin' => options.colors.get('origin'),
        'oc' => options.colors.get('oc'),
        'character' => options.colors.character,
        'species' => options.colors.get('species'),
        'content-official' => options.colors.get('content-official'),
        'content-fanmade' => options.colors.get('content-fanmade'),
        _ => options.colors.general,
      };

  @override
  TagColorsBuilder get tagColorsBuilder =>
      (options) => options.brightness.isDark
          ? const TagColors(
              general: Colors.green,
              character: Color.fromARGB(255, 73, 170, 190),
              customColors: {
                'error': Color.fromARGB(255, 212, 84, 96),
                'rating': Color.fromARGB(255, 64, 140, 217),
                'origin': Color.fromARGB(255, 111, 100, 224),
                'oc': Color.fromARGB(255, 176, 86, 182),
                'species': Color.fromARGB(255, 176, 106, 80),
                'content-official': Color.fromARGB(255, 185, 180, 65),
                'content-fanmade': Color.fromARGB(255, 204, 143, 180),
              },
            )
          : const TagColors(
              general: Color.fromARGB(255, 111, 143, 13),
              character: Color.fromARGB(255, 46, 135, 119),
              customColors: {
                'error': Color.fromARGB(255, 173, 38, 63),
                'rating': Color.fromARGB(255, 65, 124, 169),
                'origin': Color.fromARGB(255, 56, 62, 133),
                'oc': Color.fromARGB(255, 176, 86, 182),
                'species': Color.fromARGB(255, 131, 87, 54),
                'content-official': Color.fromARGB(255, 151, 142, 27),
                'content-fanmade': Color.fromARGB(255, 174, 90, 147),
              },
            );

  @override
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasRating: false,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
  );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder => (
        imageQuality,
        rawPost,
        config,
      ) =>
          castOrNull<PhilomenaPost>(rawPost).toOption().fold(
                () => rawPost.sampleImageUrl,
                (post) => config.imageDetaisQuality.toOption().fold(
                      () => post.sampleImageUrl,
                      (quality) =>
                          switch (stringToPhilomenaPostQualityType(quality)) {
                        PhilomenaPostQualityType.full =>
                          post.representation.full,
                        PhilomenaPostQualityType.large =>
                          post.representation.large,
                        PhilomenaPostQualityType.medium =>
                          post.representation.medium,
                        PhilomenaPostQualityType.tall =>
                          post.representation.tall,
                        PhilomenaPostQualityType.small =>
                          post.representation.small,
                        PhilomenaPostQualityType.thumb =>
                          post.representation.thumb,
                        PhilomenaPostQualityType.thumbSmall =>
                          post.representation.thumbSmall,
                        PhilomenaPostQualityType.thumbTiny =>
                          post.representation.thumbTiny,
                        null => post.representation.small,
                      },
                    ),
              );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<PhilomenaPost>(),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<PhilomenaPost>(),
    },
    full: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<PhilomenaPost>(),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<PhilomenaPost>(),
      DetailsPart.artistInfo: (context) => const PhilomenaArtistInfoSection(),
      DetailsPart.stats: (context) => const PhilomenaStatsTileSection(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<PhilomenaPost>(),
      DetailsPart.tags: (context) =>
          const DefaultInheritedTagList<PhilomenaPost>(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<PhilomenaPost>(),
    },
  );
}

class PhilomenaRepository implements BooruRepository {
  const PhilomenaRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return null;
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(philomenaPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(philomenaAutoCompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(emptyNoteRepoProvider);
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(emptyTagRepoProvider);
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return EmptyFavoriteRepository();
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return EmptyBooruSpecificBlacklistTagRefRepository(ref);
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => PhilomenaClient(
          baseUrl: config.url,
          dio: dio,
          apiKey: config.apiKey,
        ).getImages(tags: ['*']).then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return DefaultTagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return ImagePostLinkGenerator(baseUrl: config.url);
  }
}

class PhilomenaStatsTileSection extends ConsumerWidget {
  const PhilomenaStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: SimplePostStatsTile(
        totalComments: post.commentCount,
        favCount: post.favCount,
        score: post.score,
        votePercentText: _generatePercentText(post),
      ),
    );
  }

  String _generatePercentText(PhilomenaPost? post) {
    if (post == null) return '';
    final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
    return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
  }
}

class PhilomenaArtistInfoSection extends ConsumerWidget {
  const PhilomenaArtistInfoSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ArtistCommentary.description(post.description),
        artistTags: post.artistTags ?? {},
        source: post.source,
      ),
    );
  }
}

BooruComponents createPhilomena() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.philomena,
        constructor: (siteDef) => Philomena(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
        ),
      ),
      createBuilder: PhilomenaBuilder.new,
      createRepository: (ref) => PhilomenaRepository(ref: ref),
    );

class Philomena extends Booru {
  const Philomena({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.philomena;
}
