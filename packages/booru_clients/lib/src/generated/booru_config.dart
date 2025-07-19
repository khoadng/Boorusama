// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:equatable/equatable.dart';

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
  const PostsFeature() : super(BooruFeatureId.posts);
}

class PostFeature extends BooruFeature {
  const PostFeature() : super(BooruFeatureId.post);
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
    this.additionalConfig = const {},
  });

  final BooruFeatureId featureId;
  final EndpointType type;
  final String path;
  final String? baseUrl;
  final String? parserStrategy;
  final Map<String, String> paramMapping;
  final Map<String, dynamic> additionalConfig;
}

class SiteCapabilities {
  const SiteCapabilities({
    required this.siteUrl,
    required this.featureEndpoints,
  });

  final String siteUrl;
  final Map<BooruFeatureId, FeatureEndpoint> featureEndpoints;

  FeatureEndpoint? getEndpoint(BooruFeatureId featureId) {
    return featureEndpoints[featureId];
  }

  bool hasFeature(BooruFeatureId featureId) {
    return featureEndpoints.containsKey(featureId);
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
    type: EndpointType.api,
    path: '/index.php?page=dapi&s=post&q=index&json=1',
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

  static const _rule34xxxAutocompleteEndpoint = FeatureEndpoint(
    featureId: BooruFeatureId.autocomplete,
    type: EndpointType.api,
    path: 'https://api.rule34.xxx/autocomplete.php',
    paramMapping: {'query': 'q'},
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
  
  static const siteCapabilities = <String, SiteCapabilities>{
    'https://rule34.xxx/': SiteCapabilities(
      siteUrl: 'https://rule34.xxx/',
      featureEndpoints: {
        BooruFeatureId.posts: _postsEndpoint,
        BooruFeatureId.post: _postEndpoint,
        BooruFeatureId.autocomplete: _rule34xxxAutocompleteEndpoint,
        BooruFeatureId.comments: _commentsEndpoint,
        BooruFeatureId.notes: _notesEndpoint,
        BooruFeatureId.tags: _tagsEndpoint,
        BooruFeatureId.favorites: _favoritesEndpoint,
      },
    ),
    'https://hypnohub.net/': SiteCapabilities(
      siteUrl: 'https://hypnohub.net/',
      featureEndpoints: {
        BooruFeatureId.posts: _postsEndpoint,
        BooruFeatureId.post: _postEndpoint,
        BooruFeatureId.autocomplete: _autocompleteEndpoint,
        BooruFeatureId.comments: _commentsEndpoint,
        BooruFeatureId.notes: _notesEndpoint,
        BooruFeatureId.tags: _tagsEndpoint,
        BooruFeatureId.favorites: _favoritesEndpoint,
      },
    ),
    'https://realbooru.com/': SiteCapabilities(
      siteUrl: 'https://realbooru.com/',
      featureEndpoints: {
        BooruFeatureId.posts: _postsEndpoint,
        BooruFeatureId.post: _postEndpoint,
        BooruFeatureId.autocomplete: _autocompleteEndpoint,
        BooruFeatureId.comments: _commentsEndpoint,
        BooruFeatureId.notes: _notesEndpoint,
        BooruFeatureId.tags: _tagsEndpoint,
        BooruFeatureId.favorites: _favoritesEndpoint,
      },
    ),
    'https://xbooru.com/': SiteCapabilities(
      siteUrl: 'https://xbooru.com/',
      featureEndpoints: {
        BooruFeatureId.posts: _postsEndpoint,
        BooruFeatureId.post: _postEndpoint,
        BooruFeatureId.autocomplete: _autocompleteEndpoint,
        BooruFeatureId.comments: _commentsEndpoint,
        BooruFeatureId.notes: _notesEndpoint,
        BooruFeatureId.tags: _tagsEndpoint,
        BooruFeatureId.favorites: _favoritesEndpoint,
      },
    ),
    'https://tbib.org/': SiteCapabilities(
      siteUrl: 'https://tbib.org/',
      featureEndpoints: {
        BooruFeatureId.posts: _postsEndpoint,
        BooruFeatureId.post: _postEndpoint,
        BooruFeatureId.autocomplete: _autocompleteEndpoint,
        BooruFeatureId.comments: _commentsEndpoint,
        BooruFeatureId.notes: _notesEndpoint,
        BooruFeatureId.tags: _tagsEndpoint,
        BooruFeatureId.favorites: _favoritesEndpoint,
      },
    ),
    'https://safebooru.org/': SiteCapabilities(
      siteUrl: 'https://safebooru.org/',
      featureEndpoints: {
        BooruFeatureId.posts: _postsEndpoint,
        BooruFeatureId.post: _postEndpoint,
        BooruFeatureId.autocomplete: _autocompleteEndpoint,
        BooruFeatureId.comments: _commentsEndpoint,
        BooruFeatureId.notes: _notesEndpoint,
        BooruFeatureId.tags: _tagsEndpoint,
        BooruFeatureId.favorites: _favoritesEndpoint,
      },
    ),
  };

  static BooruFeature? createFeature(BooruFeatureId id) => switch (id) {
    BooruFeatureId.posts => const PostsFeature(),
    BooruFeatureId.post => const PostFeature(),
    BooruFeatureId.autocomplete => const AutocompleteFeature(),
    BooruFeatureId.comments => const CommentsFeature(),
    BooruFeatureId.notes => const NotesFeature(),
    BooruFeatureId.tags => const TagsFeature(),
    BooruFeatureId.favorites => const FavoritesFeature(),
  };

  static List<BooruFeature> createAllFeatures() => 
      defaultFeatures.keys.map(createFeature).whereType<BooruFeature>().toList();
}
