// Package imports:
import 'package:equatable/equatable.dart';

enum PostQualityType {
  v180x180('180x180'),
  v360x360('360x360'),
  v720x720('720x720'),
  sample('sample'),
  original('original');

  const PostQualityType(this.value);

  static PostQualityType? parse(String? value) {
    return switch (value) {
      '180x180' => PostQualityType.v180x180,
      '360x360' => PostQualityType.v360x360,
      '720x720' => PostQualityType.v720x720,
      'sample' => PostQualityType.sample,
      'original' => PostQualityType.original,
      _ => null,
    };
  }

  final String value;
}

class PostVariant extends Equatable {
  const PostVariant({
    required this.type,
    required this.url,
  });

  factory PostVariant.original(String? url) => PostVariant(
    type: PostQualityType.original,
    url: url ?? '',
  );

  factory PostVariant.sample(String? url) => PostVariant(
    type: PostQualityType.sample,
    url: url ?? '',
  );

  factory PostVariant.thumbnail(String? url) => PostVariant(
    type: PostQualityType.v180x180,
    url: url ?? '',
  );

  final PostQualityType type;
  final String url;

  @override
  List<Object?> get props => [type, url];
}

class PostVariants {
  const PostVariants._({
    required this.variants,
  });

  const PostVariants.none()
    : this._(
        variants: const {},
      );

  factory PostVariants.fromMap(
    Map<String?, String?>? map, {
    List<PostVariant> Function()? fallback,
  }) {
    final variants =
        map?.entries
            .map(
              (e) {
                final type = PostQualityType.parse(e.key);
                final url = e.value;

                return type != null && url != null
                    ? PostVariant(
                        type: type,
                        url: url,
                      )
                    : null;
              },
            )
            .nonNulls
            .toList() ??
        (fallback != null ? fallback() : _dummyVariants);

    return PostVariants._(
      variants: {
        for (final variant in variants) variant.type: variant.url,
      },
    );
  }

  static final List<PostVariant> _dummyVariants = [
    PostVariant.original(''),
    PostVariant.sample(''),
    PostVariant.thumbnail(''),
  ];

  final Map<PostQualityType, String> variants;

  String getUrl(PostQualityType type) {
    return variants[type] ?? '';
  }
}
