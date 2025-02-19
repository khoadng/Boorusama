// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../providers/details_layout_provider.dart';

void goToDetailsLayoutManagerPage(
  BuildContext context, {
  required DetailsLayoutManagerParams params,
}) {
  context.push(
    '/details_manager',
    extra: params,
  );
}
