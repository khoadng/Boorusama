// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/auth/widgets.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_parts/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import 'configs/widgets.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class PhilomenaBuilder extends BaseBooruBuilder {
  PhilomenaBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
      }) => CreateBooruConfigScope(
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
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
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
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<PhilomenaPost>(),
    );
  };

  @override
  final postDetailsUIBuilder = PostDetailsUIBuilder(
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
          const DefaultInheritedBasicTagsTile<PhilomenaPost>(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<PhilomenaPost>(),
    },
  );

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const UnknownBooruWidgetsBuilder(
        apiKeyField: DefaultBooruApiKeyField(),
      );
}
