// Project imports:
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_image_source_composer.dart';

class DanbooruImageSourceComposer implements ImageSourceComposer<PostDto> {
  DanbooruImageSourceComposer(this.booru);

  final Booru booru;

  @override
  ImageSource compose(PostDto post) {
    return ImageSource(
      thumbnail: post.previewFileUrl?.replaceAll('preview', '360x360') ?? '',
      sample: _getSample(post),
      original: post.fileUrl ?? '',
    );
  }

  String _getSample(PostDto post) {
    final preview = post.previewFileUrl ?? '';
    final sample = post.largeFileUrl ?? '';

    return preview.isNotEmpty
        ? preview.replaceAll('preview', '720x720').replaceAll('.jpg', '.webp')
        : sample;
  }
}
