// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../pages/details_layout_manager_page.dart';
import '../providers/details_layout_provider.dart';
import '../types/custom_details.dart';
import '../types/details_part.dart';

void goToDetailsLayoutManagerPage(
  BuildContext context, {
  required List<CustomDetailsPartKey> details,
  required Set<DetailsPart> availableParts,
  required Set<DetailsPart> defaultParts,
  required void Function(List<CustomDetailsPartKey> parts) onDone,
}) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) {
        return DetailsLayoutManagerPage(
          params: DetailsLayoutManagerParams(
            details: details,
            availableParts: availableParts,
            defaultParts: defaultParts,
          ),
          onDone: onDone,
        );
      },
    ),
  );
}
