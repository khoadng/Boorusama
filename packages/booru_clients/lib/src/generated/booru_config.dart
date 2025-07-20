// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:equatable/equatable.dart';

class P {
  static const apiKey = 'api-key';
  static const limit = 'limit';
  static const page = 'page';
  static const postId = 'post-id';
  static const query = 'query';
  static const tags = 'tags';
  static const userId = 'user-id';
}

enum BooruFeatureId {
  posts('posts'),
  post('post'),
  autocomplete('autocomplete'),
  comments('comments'),
  notes('notes'),
  tags('tags'),
  favorites('favorites');

  const BooruFeatureId(this.name);
  final String name;

  static BooruFeatureId? fromName(String name) {
    for (final feature in values) {
      if (feature.name == name) return feature;
    }
    return null;
  }
}

abstract class BooruFeature extends Equatable {
  const BooruFeature(this.id);
  final BooruFeatureId id;

  @override
  List<Object?> get props => [id];
}

class PostsFeature extends BooruFeature {
  const PostsFeature({
    required this.thumbnailOnly,
  }) : super(BooruFeatureId.posts);

  final bool thumbnailOnly;

  @override
  List<Object?> get props => [
    ...super.props,
    thumbnailOnly,
  ];
}

class PostFeature extends BooruFeature {
  const PostFeature({
    required this.cacheSeconds,
  }) : super(BooruFeatureId.post);

  final int cacheSeconds;

  @override
  List<Object?> get props => [
    ...super.props,
    cacheSeconds,
  ];
}

class AutocompleteFeature extends BooruFeature {
  const AutocompleteFeature() : super(BooruFeatureId.autocomplete);
}

class CommentsFeature extends BooruFeature {
  const CommentsFeature() : super(BooruFeatureId.comments);
}

class NotesFeature extends BooruFeature {
  const NotesFeature() : super(BooruFeatureId.notes);
}

class TagsFeature extends BooruFeature {
  const TagsFeature() : super(BooruFeatureId.tags);
}

class FavoritesFeature extends BooruFeature {
  const FavoritesFeature() : super(BooruFeatureId.favorites);
}

enum EndpointType {
  api('api'),
  html('html');

  const EndpointType(this.name);
  final String name;

  static EndpointType fromString(String? typeStr) {
    for (final type in values) {
      if (type.name == typeStr) return type;
    }
    return EndpointType.api;
  }
}

class FeatureEndpoint {
  const FeatureEndpoint({
    required this.featureId,
    required this.type,
    required this.path,
    this.baseUrl,
    this.parserStrategy,
    this.paramMapping = const {},
  });

  final BooruFeatureId featureId;
  final EndpointType type;
  final String path;
  final String? baseUrl;
  final String? parserStrategy;
  final Map<String, String> paramMapping;
}

abstract class EndpointOverride {
  const EndpointOverride({
    this.parserStrategy,
    this.path,
    this.baseUrl,
    this.paramMapping,
    this.type,
  });

  final String? parserStrategy;
  final String? path;
  final String? baseUrl;
  final Map<String, String>? paramMapping;
  final EndpointType? type;
}

class AutocompleteEndpointOverride extends EndpointOverride {
  const AutocompleteEndpointOverride({
    super.parserStrategy,
    super.path,
    super.baseUrl,
    super.paramMapping,
    super.type,
    this.feature,
  });

  final AutocompleteFeature? feature;
}

class PostsEndpointOverride extends EndpointOverride {
  const PostsEndpointOverride({
    super.parserStrategy,
    super.path,
    super.baseUrl,
    super.paramMapping,
    super.type,
    this.feature,
  });

  final PostsFeature? feature;
}

class PostEndpointOverride extends EndpointOverride {
  const PostEndpointOverride({
    super.parserStrategy,
    super.path,
    super.baseUrl,
    super.paramMapping,
    super.type,
    this.feature,
  });

  final PostFeature? feature;
}

class TagsEndpointOverride extends EndpointOverride {
  const TagsEndpointOverride({
    super.parserStrategy,
    super.path,
    super.baseUrl,
    super.paramMapping,
    super.type,
    this.feature,
  });

  final TagsFeature? feature;
}

class SiteCapabilities {
  const SiteCapabilities({
    required this.siteUrl,
    required this.overrides,
  });

  final String siteUrl;
  final Map<BooruFeatureId, EndpointOverride> overrides;

  AutocompleteFeature? get autocomplete {
    final override = overrides[BooruFeatureId.autocomplete] as AutocompleteEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.autocomplete] as AutocompleteFeature?;
  }

  PostsFeature? get posts {
    final override = overrides[BooruFeatureId.posts] as PostsEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.posts] as PostsFeature?;
  }

  PostFeature? get post {
    final override = overrides[BooruFeatureId.post] as PostEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.post] as PostFeature?;
  }

  TagsFeature? get tags {
    final override = overrides[BooruFeatureId.tags] as TagsEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.tags] as TagsFeature?;
  }
}


class GelbooruV2Config {
  static const _postsEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.posts,
    type: EndpointType.api,
    path: '/index.php?page=dapi&s=post&q=index&json=1',
    paramMapping: {'tags': 'tags', 'page': 'pid', 'limit': 'limit'},
  );
  static const _postEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.post,
    type: EndpointType.html,
    path: '/index.php?page=post&s=view',
    paramMapping: {'post-id': 'id'},
  );
  static const _autocompleteEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.autocomplete,
    type: EndpointType.api,
    path: '/autocomplete.php',
    paramMapping: {'query': 'q'},
  );
  static const _commentsEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.comments,
    type: EndpointType.api,
    path: '/index.php?page=dapi&s=comment&q=index',
    paramMapping: {'post-id': 'post_id'},
  );
  static const _notesEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.notes,
    type: EndpointType.html,
    path: '/index.php?page=post&s=view',
    parserStrategy: 'gelbooru-notes-html',
    paramMapping: {'post-id': 'id'},
  );
  static const _tagsEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.tags,
    type: EndpointType.html,
    path: '/index.php?page=post&s=view',
    parserStrategy: 'gelbooru-tags-sidebar',
    paramMapping: {'post-id': 'id'},
  );
  static const _favoritesEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.favorites,
    type: EndpointType.api,
    path: '/index.php?page=favorites&s=list',
    paramMapping: {},
  );

  static const globalUserParams = <String, String>{'user-id': 'user_id', 'api-key': 'api_key'};
  
  static const sites = <String>['https://rule34.xxx/', 'https://hypnohub.net/', 'https://realbooru.com/', 'https://xbooru.com/', 'https://tbib.org/', 'https://safebooru.org/'];
  
  static const defaultFeatures = <BooruFeatureId, FeatureEndpoint>{
    BooruFeatureId.posts: _postsEndpoint,
    BooruFeatureId.post: _postEndpoint,
    BooruFeatureId.autocomplete: _autocompleteEndpoint,
    BooruFeatureId.comments: _commentsEndpoint,
    BooruFeatureId.notes: _notesEndpoint,
    BooruFeatureId.tags: _tagsEndpoint,
    BooruFeatureId.favorites: _favoritesEndpoint,
  };

static const _defaults = <BooruFeatureId, BooruFeature>{
    BooruFeatureId.posts: PostsFeature(
      thumbnailOnly: false,
    ),
    BooruFeatureId.post: PostFeature(
      cacheSeconds: 600,
    ),
    BooruFeatureId.autocomplete: AutocompleteFeature(),
    BooruFeatureId.comments: CommentsFeature(),
    BooruFeatureId.notes: NotesFeature(),
    BooruFeatureId.tags: TagsFeature(),
    BooruFeatureId.favorites: FavoritesFeature(),
  };

  static const _siteCapabilities = <String, SiteCapabilities>{
    'https://rule34.xxx/': SiteCapabilities(
      siteUrl: 'https://rule34.xxx/',
      overrides: {
        BooruFeatureId.autocomplete: AutocompleteEndpointOverride(
          path: 'https://api.rule34.xxx/autocomplete.php',
        ),
      },
    ),
    'https://hypnohub.net/': SiteCapabilities(
      siteUrl: 'https://hypnohub.net/',
      overrides: {},
    ),
    'https://realbooru.com/': SiteCapabilities(
      siteUrl: 'https://realbooru.com/',
      overrides: {
        BooruFeatureId.posts: PostsEndpointOverride(
          type: EndpointType.html,
          path: '/index.php?page=post&s=list',
          parserStrategy: 'rb-posts-html',
          feature: PostsFeature(
            thumbnailOnly: true,
          ),
        ),
        BooruFeatureId.post: PostEndpointOverride(
          parserStrategy: 'rb-post-html',
        ),
        BooruFeatureId.tags: TagsEndpointOverride(
          parserStrategy: 'rb-tags-html',
        ),
      },
    ),
    'https://xbooru.com/': SiteCapabilities(
      siteUrl: 'https://xbooru.com/',
      overrides: {},
    ),
    'https://tbib.org/': SiteCapabilities(
      siteUrl: 'https://tbib.org/',
      overrides: {},
    ),
    'https://safebooru.org/': SiteCapabilities(
      siteUrl: 'https://safebooru.org/',
      overrides: {},
    ),
  };

  static SiteCapabilities? siteCapabilities(String siteUrl) {
    return _siteCapabilities[siteUrl];
  }

}

class BooruConfigRegistry {
  static T? getFeature<T extends BooruFeature>(String booruType, String siteUrl) {
    final capabilities = getSiteCapabilities(booruType, siteUrl);
    if (capabilities == null) return null;
    
    return switch (T) {
      AutocompleteFeature _ => capabilities.autocomplete,
      PostsFeature _ => capabilities.posts,
      PostFeature _ => capabilities.post,
      TagsFeature _ => capabilities.tags,
      _ => null,
    } as T?;
  }
  
  static SiteCapabilities? getSiteCapabilities(String booruType, String url) {
    return switch (booruType) {
      'gelbooru_v2' => GelbooruV2Config.siteCapabilities(url),
      _ => null,
    };
  }
}
