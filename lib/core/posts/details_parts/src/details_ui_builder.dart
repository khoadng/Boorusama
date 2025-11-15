// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'details_part.dart';

const kDefaultPostDetailsPreviewPart = {
  DetailsPart.info,
  DetailsPart.toolbar,
};

const kDefaultPostDetailsBuildablePreviewPart = {
  DetailsPart.info,
  DetailsPart.toolbar,
  DetailsPart.fileDetails,
};

class PostDetailsUIBuilder {
  const PostDetailsUIBuilder({
    this.preview = const {},
    this.full = const {},
    this.previewAllowedParts = const {
      DetailsPart.fileDetails,
      DetailsPart.source,
    },
  });

  final Set<DetailsPart> previewAllowedParts;

  final Map<DetailsPart, Widget Function(BuildContext context)> preview;
  final Map<DetailsPart, Widget Function(BuildContext context)> full;

  Set<DetailsPart> get buildablePreviewParts {
    // use full widgets, except for the ones that are not allowed
    return {
      ...previewAllowedParts.intersection(full.keys.toSet()),
      ...kDefaultPostDetailsBuildablePreviewPart,
      ...preview.keys.toSet(),
    };
  }

  Set<DetailsPart> get buildableFullParts {
    return {
      ...full.keys.toSet(),
    };
  }

  Widget? buildPart(BuildContext context, DetailsPart part) {
    final builder = full[part];
    if (builder != null) {
      return builder(context);
    }

    return null;
  }
}
