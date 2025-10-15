// Project imports:
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

final kZerochanPostDetailsUIBuilder = PostDetailsUIBuilder(
  previewSelectableParts: {
    DetailsPart.toolbar,
    DetailsPart.tags,
    DetailsPart.fileDetails,
  },
  previewDefaultEnabledParts: {
    DetailsPart.toolbar,
  },
  fullDefaultEnabledParts: {
    DetailsPart.toolbar,
    DetailsPart.source,
    DetailsPart.tags,
    DetailsPart.fileDetails,
  },
  fullSelectableParts: {
    DetailsPart.toolbar,
    DetailsPart.source,
    DetailsPart.tags,
    DetailsPart.fileDetails,
  },
  builders: {
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
