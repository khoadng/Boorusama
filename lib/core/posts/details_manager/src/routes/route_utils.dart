// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';
import '../providers/details_layout_provider.dart';

void goToDetailsLayoutManagerPage(
  WidgetRef ref, {
  required DetailsLayoutManagerParams params,
}) {
  ref.router.push(
    '/details_manager',
    extra: params,
  );
}
