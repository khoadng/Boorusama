// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../autocompletes/autocompletes.dart';
import '../blacklists/blacklisted_tag.dart';
import '../configs/config.dart';
import '../configs/create.dart';
import '../downloads/urls.dart';
import '../favorites/providers.dart';
import '../notes/notes.dart';
import '../posts/count/count.dart';
import '../posts/post/post.dart';
import '../tags/tag/tag.dart';
import 'booru_builder.dart';
import 'booru_type.dart';

class BooruEngine {
  const BooruEngine({
    required this.builder,
    required this.repository,
  });

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
}

class BooruEngineRegistry {
  final Map<BooruType, BooruEngine> _engines = {};

  void register(BooruType type, BooruEngine engine) {
    _engines[type] = engine;
  }

  BooruEngine? getEngine(BooruType type) => _engines[type];

  BooruRepository? getRepository(BooruType type) => _engines[type]?.repository;

  BooruBuilder? getBuilder(BooruType type) => _engines[type]?.builder;
}
