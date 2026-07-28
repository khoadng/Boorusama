// Project imports:
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

final kSizebooruPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<SizebooruPost>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<SizebooruPost>(),
    DetailsPart.source: (context) =>
        const DefaultInheritedSourceSection<SizebooruPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<SizebooruPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<SizebooruPost>(),
  },
);
