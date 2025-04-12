// Project imports:
import '../types/post.dart';
import '../types/post_link_generator.dart';

class PluralPostLinkGenerator<T extends Post> implements PostLinkGenerator<T> {
  PluralPostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          pathTemplate: 'posts/{id}',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}

class SingularPostLinkGenerator<T extends Post>
    implements PostLinkGenerator<T> {
  SingularPostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          pathTemplate: 'post/{id}',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}

class IntIdPostLinkGenerator implements PostLinkGenerator {
  const IntIdPostLinkGenerator({
    required this.baseUrl,
    this.pathTemplate = '',
    this.queryParams = const {},
    this.idQueryParam,
  });

  final String baseUrl;
  final String pathTemplate; // e.g. "posts/{id}" or "{id}/comments"
  final Map<String, String> queryParams;
  final String? idQueryParam;

  @override
  String getLink(Post post) {
    final url = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // Replace ID in path template
    final path = pathTemplate.replaceAll('{id}', post.id.toString());

    // Build query string
    final params = Map<String, String>.from(queryParams);
    if (idQueryParam != null) {
      params[idQueryParam!] = post.id.toString();
    }

    final pathStr = path.isNotEmpty ? '/$path' : '';
    final queryStr = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return '$url$pathStr$queryStr';
  }
}

class IndexPhpPostLinkGenerator<T extends Post>
    implements PostLinkGenerator<T> {
  IndexPhpPostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          queryParams: const {
            'page': 'post',
            's': 'view',
          },
          idQueryParam: 'id',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}

class NoLinkPostLinkGenerator<T extends Post> implements PostLinkGenerator<T> {
  const NoLinkPostLinkGenerator();

  @override
  String getLink(T post) => '';
}

class ShowPostLinkGenerator<T extends Post> implements PostLinkGenerator<T> {
  ShowPostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          pathTemplate: 'post/show/{id}',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}

class ViewPostLinkGenerator<T extends Post> implements PostLinkGenerator<T> {
  ViewPostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          pathTemplate: 'post/view/{id}',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}

class ImagePostLinkGenerator<T extends Post> implements PostLinkGenerator<T> {
  ImagePostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          pathTemplate: 'images/{id}',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}

class DirectIdPathPostLinkGenerator<T extends Post>
    implements PostLinkGenerator<T> {
  DirectIdPathPostLinkGenerator({
    required this.baseUrl,
  }) : _urlGenerator = IntIdPostLinkGenerator(
          baseUrl: baseUrl,
          pathTemplate: '{id}',
        );

  final String baseUrl;
  final IntIdPostLinkGenerator _urlGenerator;

  @override
  String getLink(T post) => _urlGenerator.getLink(post);
}
