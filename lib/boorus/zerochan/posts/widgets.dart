// Project imports:
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

final kZerochanPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<ZerochanPost>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<ZerochanPost>(),
    DetailsPart.source: (context) =>
        const DefaultInheritedSourceSection<ZerochanPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<ZerochanPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<ZerochanPost>(),
  },
);
