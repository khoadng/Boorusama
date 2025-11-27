// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/configs/auth/widgets.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/network/widgets.dart';
import '../../core/posts/details/widgets.dart';
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
  final postDetailsUIBuilder = kPhilomenaPostDetailsUIBuilder;

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const UnknownBooruWidgetsBuilder(
        httpProtocolField: HttpProtocolOptionTile(),
        apiKeyField: DefaultBooruApiKeyField(),
      );
}
