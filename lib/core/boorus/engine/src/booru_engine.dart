// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../autocompletes/autocompletes.dart';
import '../../../blacklists/blacklist.dart';
import '../../../configs/config.dart';
import '../../../configs/create.dart';
import '../../../downloads/urls.dart';
import '../../../notes/notes.dart';
import '../../../posts/count/count.dart';
import '../../../posts/favorites/providers.dart';
import '../../../posts/post/post.dart';
import '../../../search/queries/query.dart';
import '../../../tags/tag/tag.dart';
import '../../booru/booru.dart';
import 'booru_builder.dart';

class BooruEngine {
  const BooruEngine({
    required this.booru,
    required this.builder,
    required this.repository,
  });

  final Booru booru;
  final BooruBuilder builder;
  final BooruRepository repository;
}

abstract class BooruRepository {
  Ref get ref;

  PostCountRepository? postCount(BooruConfigSearch config);
  PostRepository<Post> post(BooruConfigSearch config);
  AutocompleteRepository autocomplete(BooruConfigAuth config);
  NoteRepository note(BooruConfigAuth config);
  TagRepository tag(BooruConfigAuth config);
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config);
  FavoriteRepository favorite(BooruConfigAuth config);
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config);
  BooruSiteValidator? siteValidator(BooruConfigAuth config);
  TagQueryComposer tagComposer(BooruConfigSearch config);
}

class BooruEngineRegistry {
  final Map<BooruType, BooruEngine> _engines = {};

  void register(BooruType type, BooruEngine engine) {
    _engines[type] = engine;
  }

  BooruEngine? getEngine(BooruType type) => _engines[type];

  BooruRepository? getRepository(BooruType type) => _engines[type]?.repository;

  BooruBuilder? getBuilder(BooruType type) => _engines[type]?.builder;

  List<Booru> getAllBoorus() {
    return _engines.values.map((e) => e.booru).toList();
  }
}
