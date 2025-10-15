// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'details_part.dart';

class PostDetailsUIBuilder {
  const PostDetailsUIBuilder({
    required this.builders,
    required this.previewSelectableParts,
    required this.previewDefaultEnabledParts,
    required this.fullSelectableParts,
    required this.fullDefaultEnabledParts,
  });

  final Map<DetailsPart, Widget Function(BuildContext context)> builders;

  final Set<DetailsPart> previewSelectableParts;
  final Set<DetailsPart> previewDefaultEnabledParts;

  final Set<DetailsPart> fullSelectableParts;
  final Set<DetailsPart> fullDefaultEnabledParts;

  Set<DetailsPart> get availableParts {
    return builders.keys.toSet();
  }

  Set<DetailsPart> get selectablePreviewParts {
    return previewSelectableParts.intersection(availableParts);
  }

  Set<DetailsPart> get selectableFullParts {
    return fullSelectableParts.intersection(availableParts);
  }

  Set<DetailsPart> get defaultEnabledPreviewParts {
    return previewDefaultEnabledParts.intersection(availableParts);
  }

  Set<DetailsPart> get defaultEnabledFullParts {
    return fullDefaultEnabledParts.intersection(availableParts);
  }

  Widget? buildPart(BuildContext context, DetailsPart part) {
    final builder = builders[part];
    return builder?.call(context);
  }

  bool canUseInPreview(DetailsPart part) {
    return selectablePreviewParts.contains(part);
  }

  bool canUseInFull(DetailsPart part) {
    return selectableFullParts.contains(part);
  }
}
