// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../gelbooru_v2/parsers/parsers.dart';

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
  const BooruFeature(this.id, this.endpointType);
  final BooruFeatureId id;
  final EndpointType endpointType;

  @override
  List<Object?> get props => [id, endpointType];
}

class PostsFeature extends BooruFeature {
  const PostsFeature({
    required this.thumbnailOnly,
    required this.paginationType,
    required this.fixedLimit,
  }) : super(BooruFeatureId.posts, EndpointType.api);

  final bool thumbnailOnly;
  final String paginationType;
  final dynamic fixedLimit;

  @override
  List<Object?> get props => [
    ...super.props,
    thumbnailOnly,
    paginationType,
    fixedLimit,
  ];
}

class PostFeature extends BooruFeature {
  const PostFeature({
    required this.cacheSeconds,
  }) : super(BooruFeatureId.post, EndpointType.html);

  final int cacheSeconds;

  @override
  List<Object?> get props => [
    ...super.props,
    cacheSeconds,
  ];
}

class AutocompleteFeature extends BooruFeature {
  const AutocompleteFeature() : super(BooruFeatureId.autocomplete, EndpointType.api);
}

class CommentsFeature extends BooruFeature {
  const CommentsFeature() : super(BooruFeatureId.comments, EndpointType.api);
}

class NotesFeature extends BooruFeature {
  const NotesFeature() : super(BooruFeatureId.notes, EndpointType.html);
}

class TagsFeature extends BooruFeature {
  const TagsFeature() : super(BooruFeatureId.tags, EndpointType.html);
}

class FavoritesFeature extends BooruFeature {
  const FavoritesFeature({
    required this.paginationType,
    required this.fixedLimit,
  }) : super(BooruFeatureId.favorites, EndpointType.html);

  final String paginationType;
  final int fixedLimit;

  @override
  List<Object?> get props => [
    ...super.props,
    paginationType,
    fixedLimit,
  ];
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

class AuthConfig {
  const AuthConfig({
    this.apiKeyUrl,
    this.instructionsKey,
    this.loginUrl,
    this.required,
    this.cookie,
  });

  final String? apiKeyUrl;
  final String? instructionsKey;
  final String? loginUrl;
  final bool? required;
  final String? cookie;
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

class FavoritesEndpointOverride extends EndpointOverride {
  const FavoritesEndpointOverride({
    super.parserStrategy,
    super.path,
    super.baseUrl,
    super.paramMapping,
    super.type,
    this.feature,
  });

  final FavoritesFeature? feature;
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
    this.auth,
  });

  final String siteUrl;
  final Map<BooruFeatureId, EndpointOverride> overrides;
  final AuthConfig? auth;

  AutocompleteFeature? get autocomplete {
    final override = overrides[BooruFeatureId.autocomplete] as AutocompleteEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.autocomplete] as AutocompleteFeature?;
  }

  FavoritesFeature? get favorites {
    final override = overrides[BooruFeatureId.favorites] as FavoritesEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.favorites] as FavoritesFeature?;
  }

  PostFeature? get post {
    final override = overrides[BooruFeatureId.post] as PostEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.post] as PostFeature?;
  }

  PostsFeature? get posts {
    final override = overrides[BooruFeatureId.posts] as PostsEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.posts] as PostsFeature?;
  }

  TagsFeature? get tags {
    final override = overrides[BooruFeatureId.tags] as TagsEndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.tags] as TagsFeature?;
  }
}

typedef ResponseParser<T> = T Function(Response response, Map<String, dynamic> context);

class ParserRegistry {
  static const _parsers = <String, ResponseParser>{
    'parseDefaultFavoritePostsHtml': parseDefaultFavoritePostsHtml,
    'parseDefaultPostHtml': parseDefaultPostHtml,
    'parseGelNotesHtml': parseGelNotesHtml,
    'parseGelTagsHtml': parseGelTagsHtml,
    'parseR34PostHtml': parseR34PostHtml,
    'parseRbPostHtml': parseRbPostHtml,
    'parseRbPostsHtml': parseRbPostsHtml,
    'parseRbTagsHtml': parseRbTagsHtml,
  };
  
  static ResponseParser? resolve(String? name) => _parsers[name];
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
    parserStrategy: 'parseGelNotesHtml',
    paramMapping: {'post-id': 'id'},
  );
  static const _tagsEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.tags,
    type: EndpointType.html,
    path: '/index.php?page=post&s=view',
    parserStrategy: 'parseGelTagsHtml',
    paramMapping: {'post-id': 'id'},
  );
  static const _favoritesEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.favorites,
    type: EndpointType.html,
    path: '/index.php?page=favorites&s=view',
    parserStrategy: 'parseDefaultFavoritePostsHtml',
    paramMapping: {'user-id': 'id', 'page': 'pid'},
  );

  static const globalUserParams = <String, String>{'user-id': 'user_id', 'api-key': 'api_key'};
  
  static const sites = <String>['https://rule34.xxx/', 'https://hypnohub.net/', 'https://realbooru.com/', 'https://bbooru.com/', 'https://xbooru.com/', 'https://tbib.org/', 'https://safebooru.org/'];
  
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
      paginationType: 'page',
      fixedLimit: 'null',
    ),
    BooruFeatureId.post: PostFeature(
      cacheSeconds: 600,
    ),
    BooruFeatureId.autocomplete: AutocompleteFeature(),
    BooruFeatureId.comments: CommentsFeature(),
    BooruFeatureId.notes: NotesFeature(),
    BooruFeatureId.tags: TagsFeature(),
    BooruFeatureId.favorites: FavoritesFeature(
      paginationType: 'offset',
      fixedLimit: 50,
    ),
  };

  static AuthConfig _createDefaultAuth(String siteUrl) {
    return AuthConfig(
      apiKeyUrl: '$siteUrl/index.php?page=account&s=options',
      instructionsKey: 'booru.api_key_instructions.variants_2',
      loginUrl: '$siteUrl/index.php?page=account&s=login&code=00',
      required: false,
      cookie: null,
    );
  }

  static SiteCapabilities _createDefaultSiteCapabilities(String siteUrl) {
    return SiteCapabilities(
      siteUrl: siteUrl,
      overrides: {},
      auth: _createDefaultAuth(siteUrl),
    );
  }

  static const _siteCapabilities = <String, SiteCapabilities>{
    'https://rule34.xxx/': SiteCapabilities(
      siteUrl: 'https://rule34.xxx/',
      overrides: {
        BooruFeatureId.autocomplete: AutocompleteEndpointOverride(
          path: 'https://api.rule34.xxx/autocomplete.php',
        ),
        BooruFeatureId.favorites: FavoritesEndpointOverride(
          parserStrategy: 'parseDefaultFavoritePostsHtml',
        ),
        BooruFeatureId.post: PostEndpointOverride(
          parserStrategy: 'parseR34PostHtml',
        ),
      },
      auth: AuthConfig(
        apiKeyUrl: 'https://rule34.xxx/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_1',
        loginUrl: 'https://rule34.xxx/index.php?page=account&s=login&code=00',
        required: true,
      ),
    ),
    'https://hypnohub.net/': SiteCapabilities(
      siteUrl: 'https://hypnohub.net/',
      overrides: {
        BooruFeatureId.post: PostEndpointOverride(
          parserStrategy: 'parseDefaultPostHtml',
        ),
      },
      auth: AuthConfig(
        apiKeyUrl: 'https://hypnohub.net/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_2',
        loginUrl: 'https://hypnohub.net/index.php?page=account&s=login&code=00',
        required: false,
      ),
    ),
    'https://realbooru.com/': SiteCapabilities(
      siteUrl: 'https://realbooru.com/',
      overrides: {
        BooruFeatureId.posts: PostsEndpointOverride(
          type: EndpointType.html,
          path: '/index.php?page=post&s=list',
          parserStrategy: 'parseRbPostsHtml',
          feature: PostsFeature(
            thumbnailOnly: true,
            paginationType: 'offset',
            fixedLimit: 42,
          ),
        ),
        BooruFeatureId.post: PostEndpointOverride(
          parserStrategy: 'parseRbPostHtml',
        ),
        BooruFeatureId.tags: TagsEndpointOverride(
          parserStrategy: 'parseRbTagsHtml',
        ),
      },
      auth: AuthConfig(
        apiKeyUrl: 'https://realbooru.com/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_2',
        loginUrl: 'https://realbooru.com/index.php?page=account&s=login&code=00',
        required: false,
      ),
    ),
    'https://bbooru.com/': SiteCapabilities(
      siteUrl: 'https://bbooru.com/',
      overrides: {},
      auth: AuthConfig(
        apiKeyUrl: 'https://bbooru.com/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_2',
        loginUrl: 'https://bbooru.com/index.php?page=account&s=login&code=00',
        required: false,
        cookie: 'adult_mode=1',
      ),
    ),
    'https://xbooru.com/': SiteCapabilities(
      siteUrl: 'https://xbooru.com/',
      overrides: {},
      auth: AuthConfig(
        apiKeyUrl: 'https://xbooru.com/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_2',
        loginUrl: 'https://xbooru.com/index.php?page=account&s=login&code=00',
        required: false,
      ),
    ),
    'https://tbib.org/': SiteCapabilities(
      siteUrl: 'https://tbib.org/',
      overrides: {},
      auth: AuthConfig(
        apiKeyUrl: 'https://tbib.org/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_2',
        loginUrl: 'https://tbib.org/index.php?page=account&s=login&code=00',
        required: false,
      ),
    ),
    'https://safebooru.org/': SiteCapabilities(
      siteUrl: 'https://safebooru.org/',
      overrides: {},
      auth: AuthConfig(
        apiKeyUrl: 'https://safebooru.org/index.php?page=account&s=options',
        instructionsKey: 'booru.api_key_instructions.variants_2',
        loginUrl: 'https://safebooru.org/index.php?page=account&s=login&code=00',
        required: false,
      ),
    ),
  };

  static SiteCapabilities siteCapabilities(String siteUrl) {
    return _siteCapabilities[siteUrl] ?? _createDefaultSiteCapabilities(siteUrl);
  }

}

class BooruConfigRegistry {
  static T? getFeature<T extends BooruFeature>(String booruType, String siteUrl) {
    final capabilities = getSiteCapabilities(booruType, siteUrl);
    if (capabilities == null) return null;

    return switch (T) {
      AutocompleteFeature _ => capabilities.autocomplete,
      FavoritesFeature _ => capabilities.favorites,
      PostFeature _ => capabilities.post,
      PostsFeature _ => capabilities.posts,
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
