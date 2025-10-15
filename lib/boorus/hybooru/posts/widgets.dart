// Project imports:
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

final kHybooruPostDetailsUIBuilder = PostDetailsUIBuilder(
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
    DetailsPart.tags,
    DetailsPart.fileDetails,
  },
  fullSelectableParts: {
    DetailsPart.toolbar,
    DetailsPart.tags,
    DetailsPart.fileDetails,
  },
  builders: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<HybooruPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<HybooruPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<HybooruPost>(),
  },
);
